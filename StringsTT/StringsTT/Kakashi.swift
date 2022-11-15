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
    
    var startTime: Date?
    var endTime: Date?
    
    convenience init(path: String, targetPath: String) {
        self.init()
        self.path = path
        self.tPath = targetPath
    }
    
    /// 忍术： 一键拷贝
    func ninjutsuCopyPaste() {
        print("🐝🐝🐝 开始处理\ntime = \(Date().timeString())")
        findSubPaths()
        upgradeNojiezi()
        print("🐝🐝🐝 处理完成, 正在导出到\(self.tPath)")
        outputFiles.forEach { file in
            do {
                let dir = (file.path as NSString).deletingLastPathComponent
                if FileManager.default.fileExists(atPath: dir) == false {
                    try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
                }
                try file.write()
            } catch let error {
                print(error.localizedDescription)
            }
        }
        print("🐝🐝🐝 导出成功 🎉🎉🎉\ntime = \(Date().timeString())")
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
                let mLine = modifyFileInfo(line: line)
//                for (key, value) in self.tmNames {
//                    if mLine.contains(key) {
//                        print("正在将\(key)替换成\(value)")
//                        mLine = mLine.replacingOccurrences(of: key, with: value)
//                    }
//                }
                otLines.append(mLine)
            }
            var otFileString = otLines.joined(separator: "\n")
            for (key, value) in tmNames {
                if otFileString.contains(key) {
                    print("正在将\(key)替换成\(value)")
                    otFileString = otFileString.replacingOccurrences(of: key, with: value)
                }
            }
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
        let readFile = File(path: filePath)
        
        // 将需要修改的文件类名放入字典中
        let key = readFile.name.replacingOccurrences(of: ".swift", with: "")
        //改个前缀
        var value = key.replacingOccurrences(of: "WL", with: "NOV")
        
        let dic = [
            "User": "Person",
            "TR": "TaskReward",
            "Video": "Movie",
            "Shop": "BuySth",
            "Pinglun": "Discuss",
            "Manager": "Tool",
            "Bottle": "Flask",
            "Call": "RingUp",
            "Dynamic": "Trends",
            "Gift": "GemPack",
            "Hongbao": "RedPaper",
            "IAP": "Recharge",
            "ImagePicker": "PhotoPicker"
        ]
        //文字修改
        for (key, rvalue) in dic {
            if value.contains(key) {
                value = value.replacingOccurrences(of: key, with: rvalue)
            }
        }
        tmNames[key] = value
        
        
        let otPath = self.tPath + "/" + (file as NSString).deletingLastPathComponent + "/" + value + ".swift"
        var otFile = File(path: otPath)
        otFile.contents = (try? readFile.read()) ?? ""
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
            let randomDate = Date().addingTimeInterval(TimeInterval(86400 * Int.random(in: 0...7)))
            let date = randomDate.timeString("yyyy/MM/dd")
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
