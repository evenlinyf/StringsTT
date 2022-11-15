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
    
    /// 文件暂存
    private var files: [File] = []
    
    private var outputFiles: [File] = []
    
    /// 需要修改的类名
    private var tmNames: [String: String] = [:]
    
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
        print("🐝🐝🐝 处理完成, 正在导出到\(self.tPath)")
        outputFiles.forEach { try? $0.write() }
        print("🐝🐝🐝 导出成功 🎉🎉🎉")
    }
    
    /// 修改
    private func upgradeNojiezi() {
        subPaths.forEach { file in
            self.copyEachFile(file: file)
        }
        print("🐝🐝🐝 准备了\(files.count)个待处理的文件, 需要替换的类名有\n\(tmNames)\n<<<<<<<<<<")
        
        for file in files {
            print("🐝 正在处理 \(file.name)")
            var otFile = File(path: file.path)
            var otLines: [String] = []
            file.contents.components(separatedBy: "\n").forEach { line in
                //修改工程名、等
                var mLine = modifyFileInfo(line: line)
                for (key, value) in self.tmNames {
                    if mLine.contains(key) {
                        print("正在将\(key)替换成\(value)")
                        mLine = mLine.replacingOccurrences(of: key, with: value)
                    }
                }
                otLines.append(mLine)
            }
            let otFileString = otLines.joined(separator: "\n")
            otFile.contents = otFileString
            self.outputFiles.append(otFile)
        }
    }
    
    private func copyEachFile(file: String) {
        let filePath = self.path + "/" + file
        guard FileManager.default.fileExists(atPath: filePath) else {
            print("🈲 文件不存在")
            return
        }
        let file = File(path: filePath)
        
        // 将需要修改的文件类名放入字典中
        if file.name.hasPrefix("WL") {
            //添加需要修改的类名
            let key = file.name.replacingOccurrences(of: ".swift", with: "")
            let value = key.replacingOccurrences(of: "WL", with: "NOV")
            tmNames[key] = value
        }
        
        //改个前缀
        let otFileName = file.name.replacingOccurrences(of: "WL", with: "NOV")
        let otPath = self.tPath + "/" + otFileName
        var otFile = File(path: otPath)
        otFile.contents = (try? file.read()) ?? ""
        self.files.append(otFile)
        
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
