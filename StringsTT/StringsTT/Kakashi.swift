//
//  Kakashi.swift
//  StringsTT
//
//  Created by Even Lin on 2022/11/12.
//  Copyright © 2022 cn.evenlin. All rights reserved.
//  Copy Ninja

import Foundation

class Kakashi: NSObject {
    
    private var path: String = ""
    private var tPath: String = ""
    
    private var subPaths: [String] = []
    
    convenience init(path: String, targetPath: String) {
        self.init()
        self.path = path
        self.tPath = targetPath
    }
    
    /// 忍术： 一键拷贝
    func ninjutsuCopyPaste() {
        findSubPaths()
        upgradeNojiezi()
        print("处理完成🎉🎉🎉")
    }
    
    /// 修改
    private func upgradeNojiezi() {
        subPaths.forEach { file in
            self.processEachFile(file: file)
        }
    }
    
    private func processEachFile(file: String) {
        let filePath = self.path + "/" + file
        guard FileManager.default.fileExists(atPath: filePath) else {
            print("🈲 文件不存在")
            return
        }
        let file = File(path: filePath)
        print("正在处理\(filePath)")
        
        var otLines: [String] = []
        
        //文件解析成字符串
        guard let fileString = try? file.read() else { return }
        
        let lines = fileString.components(separatedBy: "\n")
        lines.forEach { line in
            let mLine = modifyFileInfo(line: line)
            otLines.append(mLine)
        }
        
        let otFileString = otLines.joined(separator: "\n")
        //改个前缀
        let otFileName = filePath.components(separatedBy: "/").last?.replacingOccurrences(of: "WL", with: "NOV") ?? "FileNameError.swift"
        let otPath = self.tPath + "/" + otFileName
        try? File(path: otPath).write(contents: otFileString)
        
    }
    
    // 更改文件信息（文件名， 工程名， 创建人， 日期， CopyRight）
    private func modifyFileInfo(line: String) -> String {
        guard line.hasPrefix("//") else { return line }
        
        let oldProjName = "JulyChat"
        let newProjName = "novet"
        
//        let oldCreatorName = "holla"
        let newCreatorName = "noveight"
        
        let oldCopyRight = "Copyright © 2022 Weilin Network Technology. All rights reserved."
        let newCopyRight = ""
        
        var mLine = line
        
        if mLine.hasPrefix("//") {
            //修改工程名、创建人、日期
            mLine = mLine.replacingOccurrences(of: oldProjName, with: newProjName)
            mLine = mLine.replacingOccurrences(of: oldCopyRight, with: newCopyRight)
        }
        if mLine.hasPrefix("//  Created by") {
            let date = Date().timeString("yyyy/MM/dd")
            mLine = "//  Created by \(newCreatorName) on \(date)."
        }
        return mLine
    }
}


extension Kakashi {
    private func findSubPaths() {
        let fileTypes: [String] = [".swift", ".m", ".h"]
        fileTypes.forEach { type in
            let sub = try? FileFinder.paths(for: type, path: self.path)
            if let sub = sub {
                self.subPaths.append(contentsOf: sub)
            }
        }
        print("找到了\(subPaths.count)个文件 >>> \(subPaths)")
    }
}
