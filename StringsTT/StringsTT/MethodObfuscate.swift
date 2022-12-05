//
//  MethodObfuscate.swift
//  StringsTT
//
//  Created by Even Lin on 2022/11/18.
//  Copyright © 2022 cn.evenlin. All rights reserved.
//

import Foundation

class MethodObfuscate: NSObject {
    
    /// 私有方法集合
    private var priMethods: Set<String> = []
    
    /// 公开方法集合
    private var pubMethods: Set<String> = []
    
    var methods: [String] = []
    
    /// 记录方法大爆炸后单词出现的次数
    private var keys: [String: Int] = [:]
    
    
    /// 找出文件路径下所有Swift文件的所有方法
    /// - Parameter path: 文件路径
    func findAllMethods(at path: String) -> [String] {
        let subPaths = try? FileFinder.paths(for: ".swift", path: path)
        guard let subPaths = subPaths, subPaths.count > 0 else {
            print("没有找到swift文件")
            return []
        }
        print("找到了\(subPaths.count)个swift文件")
        subPaths.forEach { subPath in
            let filePath = path + "/" + subPath
            self.priMethods.removeAll()
            if let fileString = try? File(path: filePath).read() {
                var toChangeFS = fileString
                fileString.components(separatedBy: "\n").forEach { line in
                    self.parse(line: line)
                }
                let tPrefix = "nov_"
                //修改私有方法
                self.priMethods.forEach { method in
                    if method.hasPrefix(tPrefix) == false {
                        toChangeFS = toChangeFS.replacingOccurrences(of: "\(method)(", with: "\(tPrefix)\(method)(")
                        toChangeFS = toChangeFS.replacingOccurrences(of: "#selector(\(method)", with: "#selector(\(tPrefix)\(method)")
                    }
                }
                let toFile = File(path: filePath, contents: "")
                try? toFile.write(contents: toChangeFS)
            }
        }
        print("☁️ 找到了\(priMethods.count)个 private func , \(pubMethods.count)个public func")
        
        self.methods = Array(priMethods) + Array(pubMethods)
        parseMethods()
        print("☁️ 大爆炸后各个单词出现的次数为 = ")
        print(keys.sorted(by: {$0.value > $1.value}).enumerated().reduce("", { partialResult, dic in
            return partialResult + dic.element.key + " = " + String(dic.element.value) + "\n"
        }))
        return methods
    }
    
    /// 解析文件的每一行
    private func parse(line: String) {
        var shLine = line.replacingOccurrences(of: " ", with: "")
        //公开方法
        if shLine.hasPrefix("func") || shLine.hasPrefix("publicfunc") {
            shLine = shLine.replacingOccurrences(of: "publicfunc", with: "")
            shLine = shLine.replacingOccurrences(of: "func", with: "")
            shLine = shLine.components(separatedBy: "(").first ?? "⚠️⚠️⚠️⚠️"
            pubMethods.insert(shLine)
        }
        //私有方法
        if shLine.hasPrefix("privatefunc") {
            shLine = shLine.replacingOccurrences(of: "privatefunc", with: "").components(separatedBy: "(").first ?? "⚠️⚠️⚠️⚠️"
            priMethods.insert(shLine)
//                        var tString = fileString.replacingOccurrences(of: shLine, with: "prefix_shLine")
//                        let tFile = File(path: filePath).write(contents: tString)
        }
        
    }
    
    /// 方法大爆炸
    private func parseMethods() {
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
