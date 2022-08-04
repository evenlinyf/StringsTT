//
//  LocalFinder.swift
//  StringsTT
//
//  Created by EvenLin on 2022/8/4.
//

import Foundation

class LocalFinder: NSObject {
    
    private var localizableStrings: [String] = []
    private var localKeys: Set<String> = []
    
    /// 找到某个文件夹下所有包含文件类型中符合正则表达式的结果
    /// Find all the strings which matches the regex in the filetypes under the path
    /// - Parameters:
    ///   - regex: 正则表达式
    ///   - path: 文件夹路径
    ///   - fileTypes: 文件类型 for example [".swift", ".m"]
    /// - Returns: 返回所有找到的不重复的结果
    func findAllMatches(regex: String, in path: String, for fileTypes: [String]) -> [String]? {
        return nil
    }
    
    func findSubPaths(path: String) {
        do {
            let sub = try FileFinder.paths(for: ".swift", path: path)
            print(sub)
            sub.forEach { swiftFile in
                self.parseSwiftFile(path: path + "/" + swiftFile)
            }
            parseLine()
            print(sub.count)
            print(localizableStrings.joined(separator: "\n"))
            print(localizableStrings.count)
            print("找到了\(sub.count)个swift文件\n收集到\(localizableStrings.count)条带.local的字符串")
//            showTip("找到了\(sub.count)个swift文件\n收集到\(localizableStrings.count)条带.local的字符串")
        } catch let error {
            print(error)
        }
    }
    
    func parseSwiftFile(path: String) {
        print("开始解析\(path)")
        guard FileManager.default.fileExists(atPath: path) else {
            print("文件不存在")
            return
        }
        let file = File(path: path)
        let fileString = try? file.read()
        guard let fileString = fileString else { return }
        let lines = fileString.components(separatedBy: "\n").filter {$0.hasPrefix("//") == false && $0.contains(".local")}
        localizableStrings.append(contentsOf: lines)
    }
    
    func parseLine() {
        localizableStrings.forEach { line in
            let regex = try? NSRegularExpression(pattern: "\"[^.local][^\"]+\".local")//以"开头, 以".local结尾, 中间不包含 .local 和 "
            if let res = regex?.matches(in: line, range: NSRange(location: 0, length: line.count)) {
                if res.count > 0 {
                    res.forEach { textCheckingResult in
                        let key = (line as NSString).substring(with: textCheckingResult.range).replacingOccurrences(of: ".local", with: "")
                        self.localKeys.insert(key)
                    }
                }
            }
        }
        print("找到\(localKeys.count)个需要国际化的字符串")
        var file = StringFile()
        localKeys.forEach { key in
            let value = key.replacingOccurrences(of: "\"", with: "")
            file.dic[key] = value
        }
        file.save()
        print(localKeys)
    }
}
