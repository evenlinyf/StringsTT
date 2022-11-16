//
//  Kakashi.swift
//  StringsTT
//
//  Created by Even Lin on 2022/11/12.
//  Copyright © 2022 cn.evenlin. All rights reserved.
//  Copy Ninja 快速复制一份工程的代码， 并且根据replaceKeys修改路径文件夹名称和类名称

import Foundation

private struct OldProjInfo {
    let projName: String = "JulyChat"
    let author: String = ""
    let prefix: String = "WL"
    let copyRight: String = ""
}

private struct NewProjInfo {
    let projName: String = "novet"
    let author: String = "noveight"
    let prefix: String = "NOV"
    let copyRight: String = ""
    
    /// 文件重命名替换
    let replaceKeys: [String: String] = [
        "User": "Person",
        "TR": "TaskReward",
        "Video": "Movie",
        "Shopping": "Plaza",
        "Shop": "Plaza",
        "Pinglun": "Discuss",
        "Manager": "Helper",
        "Bottle": "Flask",
        "Call": "RingUp",
        "Dynamic": "Trends",
        "Gift": "Present",
        "Hongbao": "RedPaper",
        "IAP": "Recharge",
        "VM": "ViewModel",
        "ImagePicker": "PhotoPicker",
        "Publish": "Post",
        "Chat": "Session",
        "API": "Interface",
        "TipOff": "Report",
        "RegLogin": "Register"
    ]
    
    func fileCreateTime() -> String {
        return "2022/11/\(Int.random(in: 0...20))"
    }
}

class Kakashi: NSObject {
    
    private let old = OldProjInfo()
    private let new = NewProjInfo()
    
    private var path: String = ""
    private var tPath: String = ""
    
    /// 文件暂存, 待修改
    private var files: [File] = []
    
    private var outputFiles: [File] = []
    
    /// 需要修改的类名
    private var tmNames: [String: String] = [:]
    
    private var subPaths: [String] = []
    
    private var startTime: Date?
    private var endTime: Date?
    
    convenience init(path: String, targetPath: String) {
        self.init()
        self.path = path
        self.tPath = targetPath
    }
    
    /// 忍术： 一键拷贝
    func ninjutsuCopyPaste() {
        
        startTime = Date()
        print("🐝🐝🐝 开始处理\ntime = \(startTime!.timeString())")
        findSubPaths()
        upgradeNojiezi()
        print("🐝🐝🐝 处理完成, 正在导出\(outputFiles.count)个文件到\(self.tPath)")
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
        endTime = Date()
        let ti = endTime!.timeIntervalSince(startTime!)
        print("🐝🐝🐝 导出成功 🎉🎉🎉, 耗时\(ti)秒 \ntime = \(endTime!.timeString())")
    }
    
    /// 修改
    private func upgradeNojiezi() {
        subPaths.forEach { file in
            //处理文件路径和文件名， 存储需要替换的类名
            self.copyEachFile(file: file)
        }
        print("🐝🐝🐝 准备了\(files.count)个待处理的文件, 需要替换的类名有\n\(tmNames)\n<<<<<<<<<<")
        
        for file in files {
            print("🐝 正在处理 \(file.name)")
//            let otFilePath = tPath + "/" + file.name
            let otFilePath = file.path
            var otFile = File(path: otFilePath)
            var otLines: [String] = []
            file.contents.components(separatedBy: "\n").forEach { line in
                let mLine = modifyFileInfo(line: line)
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
        let fullFileName = readFile.name.replacingOccurrences(of: ".\(readFile.type)", with: "")
        //去除旧前缀
        var fileModifiedName = fullFileName.replacingOccurrences(of: old.prefix, with: "")
        
        var middlePath = (file as NSString).deletingLastPathComponent
        //文字修改
        for (key, rvalue) in new.replaceKeys {
            //如果文件名包含以上key， 替换成对应value
            if fileModifiedName.contains(key) {
                fileModifiedName = fileModifiedName.replacingOccurrences(of: key, with: rvalue)
            }
            //如果中间路径也包含以上key，也替换成value
            if middlePath.contains(key) {
                middlePath = middlePath.replacingOccurrences(of: key, with: rvalue)
            }
        }
        //添加新前缀
        fileModifiedName = new.prefix + fileModifiedName
        
        tmNames[fullFileName] = fileModifiedName
        
        let otPath = "\(tPath)/\(middlePath)/\(fileModifiedName).\(readFile.type)"
        var otFile = File(path: otPath)
        otFile.contents = (try? readFile.read()) ?? ""
        self.files.append(otFile)
        
    }
    
    // 更改文件信息（工程名， 创建人， 日期， CopyRight）
    private func modifyFileInfo(line: String) -> String {
        guard line.hasPrefix("//") else { return line }
        var mLine = line
        if mLine.contains(old.projName) {
            //修改工程名、创建人、日期
            mLine = mLine.replacingOccurrences(of: old.projName, with: new.projName)
        }
        if mLine.hasPrefix("//  Created by") {
            mLine = "//  Created by \(new.author) on \(new.fileCreateTime())."
        }
        if mLine.hasPrefix("//  Copyright") {
            mLine = "//  " + new.copyRight
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
