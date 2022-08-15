//
//  LocalFinder.swift
//  StringsTT
//
//  Created by EvenLin on 2022/8/4.
//

import Foundation

class LocalFinder: NSObject {
    
    private var lines: [String] = []
    private var localKeys: Set<String> = []
    
    private var regex: String = ""
    private var path: String = ""
    private var fileTypes: [String] = []
    
    /// 找到某个文件夹下所有包含文件类型中符合正则表达式的结果
    /// Find all the strings which matches the regex in the filetypes under the path
    /// - Parameters:
    ///   - regex: 正则表达式
    ///   - path: 文件夹路径
    ///   - fileTypes: 文件类型 for example [".swift", ".m"]
    /// - Returns: 返回所有找到的不重复的结果
    func findAllMatches(regex: String, in path: String, for fileTypes: [String]) -> [String] {
        self.regex = regex
        self.path = path
        self.fileTypes = fileTypes
        findSubPaths()
        return Array(localKeys)
    }
    
    private func findSubPaths() {
        var subPaths: [String] = []
        self.fileTypes.forEach { type in
            let sub = try? FileFinder.paths(for: type, path: self.path)
            if let sub = sub {
                subPaths.append(contentsOf: sub)
            }
        }
        lines.removeAll()
        //遍历每一个文件路径
        subPaths.forEach { swiftFile in
            let fullPath = self.path + "/" + swiftFile
            //将每一个文件分割成行， 放在数组中
            self.separateFileToLines(path: fullPath)
        }
        parseLines()
    }
    
    private func separateFileToLines(path: String) {
        print("开始解析文件\(path)")
        guard FileManager.default.fileExists(atPath: path) else {
            print("文件不存在\(path)")
            return
        }
        let file = File(path: path)
        let fileString = try? file.read()
        guard let fileString = fileString else { return }
        let fileLines = fileString.components(separatedBy: "\n")
        lines.append(contentsOf: fileLines)
    }
    
    private func parseLines() {
        lines.forEach { line in
            let regex = try? NSRegularExpression(pattern: self.regex)
            if let res = regex?.matches(in: line, range: NSRange(location: 0, length: line.count)) {
                if res.count > 0 {
                    res.forEach { textCheckingResult in
                        let key = (line as NSString).substring(with: textCheckingResult.range)
                        self.localKeys.insert(key)
                    }
                }
            }
        }
        print(localKeys)
        print("找到符合正则\(regex)的字符串\(localKeys.count)条")
    }
    
    func exportFile() {
        var file = StringFile()
        localKeys.forEach { key in
            let value = key.replacingOccurrences(of: ".local", with: "").replacingOccurrences(of: "\"", with: "")
            file.dic[value] = value
        }
        file.save()
    }
}
