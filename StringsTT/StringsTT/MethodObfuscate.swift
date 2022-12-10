//
//  MethodObfuscate.swift
//  StringsTT
//
//  Created by Even Lin on 2022/11/18.
//  Copyright © 2022 cn.evenlin. All rights reserved.
//

import Foundation

class MethodObfuscate: NSObject {
    
    /// 文件夹路径
    private var path: String = ""
    
    /// 文件夹子路径 (所有 .swift 路径)
    private var subPaths: [String] = []
    
    /// 私有方法集合
    private var priMethods: Set<String> = []
    
    /// 公开方法集合
    private var pubMethods: Set<String> = []
    
    /// 某个文件的私有方法集合
    private var filePriMethods: Set<String> = []
    
    private var filePriMethodsMap: [String: [String]] = [:]
    
    /// 所有的方法
    var methods: [String] = []
    
    /// 记录方法大爆炸后单词出现的次数
    private var keys: [String: Int] = [:]
    
    var progress: YFProgress?
    
    /// 找出文件路径下所有Swift文件的所有方法
    /// - Parameter path: 文件路径
    func findAllMethods(at path: String) -> [String] {
        self.path = path
        let subPaths = try? FileFinder.paths(for: ".swift", path: path)
        guard let subPaths = subPaths, subPaths.count > 0 else {
            YFLog("没有找到swift文件")
            return []
        }
        self.subPaths = subPaths
        YFLog("找到了\(subPaths.count)个swift文件")
        self.progress?.onProgress?("找到了\(subPaths.count)个swift文件")
        subPaths.forEach { subPath in
            let filePath = path + "/" + subPath
            //清空当前文件的所有私有方法
            self.filePriMethods.removeAll()
            
            if let fileString = try? File(path: filePath).read() {
//                var toChangeFS = fileString
                fileString.components(separatedBy: "\n").forEach { line in
                    self.parse(line: line)
                    // 将当前文件所有私有方法当成 value 赋值 给文件路径的 key
                    self.filePriMethodsMap[filePath] = Array(self.filePriMethods)
                }
            }
        }
        YFLog("☁️ 找到了\(priMethods.count)个 private func , \(pubMethods.count)个public func， 文件对应的方法有\n \(filePriMethodsMap)")
        self.progress?.onProgress?("☁️ 找到了\(priMethods.count)个 private func , \(pubMethods.count)个public func")
        self.methods = Array(priMethods) + Array(pubMethods)
        methodExplosion()
        YFLog("☁️ 大爆炸后各个单词出现的次数为 = ")
        YFLog(keys.sorted(by: {$0.value > $1.value}).enumerated().reduce("", { partialResult, dic in
            return partialResult + dic.element.key + " = " + String(dic.element.value) + "\n"
        }))
        return methods
    }
    
    /// 解析文件的每一行, 解析方法
    private func parse(line: String) {
        var shLine = line.replacingOccurrences(of: " ", with: "")
        
        //公开方法
        if shLine.hasPrefix("func") || shLine.hasPrefix("publicfunc") || shLine.hasPrefix("internalfunc") || shLine.hasPrefix("openfunc") {
            shLine = shLine.components(separatedBy: "func").last?.components(separatedBy: "(").first ?? "⚠️⚠️⚠️⚠️"
            if isSystemMethod(shLine) == false {
                pubMethods.insert(shLine)
            }
        }
        
        //私有方法
        if shLine.contains("privatefunc") {
            shLine = shLine.components(separatedBy: "func").last?.components(separatedBy: "(").first ?? "⚠️⚠️⚠️⚠️"
            filePriMethods.insert(shLine)
            priMethods.insert(shLine)
        }
        
    }
    
    private func isSystemMethod(_ method: String) -> Bool {
        let systemMethods: [String] = [
            "init",
            "viewDidLoad",
            "application",
            "addTarget",
            "title",
            "navigationController",
            "gesture",
            "numberOf",
            "pagerView",
            "tableView",
            "collectionView",
            "scrollView",
            "textView",
            "textField",
            "tabBarController",
            "mapping",
            "color",
            "transformFromJSON",
            "transformToJSON",
            "webSocket",
            "svgaPlayerDidFinish",
            "load",
            "download",
            "xgPush"
        ]
        for m in systemMethods {
            if method.hasPrefix(m) {
                return true
            }
        }
        return false
    }
    
    /// 方法大爆炸
    private func methodExplosion() {
        for method in methods {
            var small: String = ""
            method.forEach { char in
                if char.isUppercase && small.count > 0 {
                    if let value: Int = self.keys[small] {
                        self.keys[small.lowercased()] = value + 1
                    } else {
                        self.keys[small.lowercased()] = 1
                    }
                    small = String(char)
                } else {
                    small = small + String(char)
                }
            }
        }
    }
}

extension MethodObfuscate {
    /// 混淆方法名
    func obfuscateMethods() {
        YFLog("开始混淆")
        self.progress?.onProgress?("开始混淆")
        let startTime = Date()
        // 遍历每一个文件
        subPaths.forEach { subPath in
            let filePath = path + "/" + subPath
            if var fileString = try? File(path: filePath).read() {
                var lines: [String] = []
                fileString.components(separatedBy: "/n").forEach { line in
                    var tLine = line
                    if let priMethods = self.filePriMethodsMap[filePath], priMethods.count > 0 {
                        // 替换私有方法
                        priMethods.forEach { method in
                            tLine = self.replaceMethod(method, for: tLine)
                        }
                    }
                    
                    // 替换公有方法
                    pubMethods.forEach { method in
                        if line.contains(method) {
                            tLine = self.replaceMethod(method, for: tLine)
                        }
                    }
                    lines.append(tLine)
                }
                let tFileString = lines.joined(separator: "\n")
                
                let toFile = File(path: filePath, contents: "")
                try? toFile.write(contents: tFileString)
            }
        }
        let timeInterval = Date().timeIntervalSince(startTime)
        YFLog("混淆完成, 耗时\(timeInterval)")
        self.progress?.onComplete?("混淆完成, 耗时\(timeInterval)")
    }
    
    private func replaceMethod(_ method: String, for line: String) -> String {
        let oPrefix = "oldPrefix_"
        let tPrefix = "nov_"
        if method.hasPrefix(tPrefix) { return line }
        guard line.contains(method) else { return line }
        
        var tMethod = method
        var tLine = line
        if method.hasPrefix(oPrefix) {
            //替换前缀
            tMethod = method.replacingOccurrences(of: oPrefix, with: tPrefix)
        } else {
            //添加前缀
            tMethod = tPrefix + method
        }
        
        var shouldReplace = false
        let invokerStrings = methodInvokerStyles(method: method)
        for ivString in invokerStrings {
            if line.contains(ivString) {
                shouldReplace = true
                break
            }
        }
        if shouldReplace {
            tLine = line.replacingOccurrences(of: method, with: tMethod)
        }
        return tLine
    }
    
    
    // 方法声明或调用
    // 列出包含方法调用和声明的所有情况, 用于判断某一行是否有某个方法的调用或声明， 如果有， 予以替换
    // 声明， 直接调用， .语法调用， 直接调用+尾随闭包， .语法+尾随闭包, #selector(
    private func methodInvokerStyles(method: String) -> [String] {
        return [
            "func \(method)",
            "\(method)(",
            ".\(method)(",
            "\(method) {",
            ".\(method) {",
            "#selector(\(method)"
        ]
    }
}
