//
//  TransViewModel.swift
//  StringsTT
//
//  Created by EvenLin on 2022/4/1.
//

import Cocoa

typealias Progress = (_ progress: Int, _ all: Int) -> Void

typealias Complete = () -> Void

class TransViewModel: NSObject {
    
    var file = StringFile()
    var tFile = StringFile()
    var ttKeys: [String] = []
    
    var language: String = "en"
    
    /// 翻译并发数量（循环请求翻译接口次数）
    var concurrentCount: Int = 100
    /// 第几个一百个
    var transProgress: Int = 0
    /// 当前翻译第几个
    var currentIndex: Int = 0
    
    private var progressAction: Progress?
    private var completeAction: Complete?
    
    func parseFiles(filePath: String, tFilePath: String) {
        file.path = filePath
        if FileManager.default.fileExists(atPath: tFilePath) {
            tFile.path = tFilePath
        }
        
        guard file.dic.count > 0 else {
            return
        }
        
        ttKeys = file.keys.filter{tFile.keys.contains($0) == false}
    }
    
    func fileStatusDesc() -> String {
        return "检测到 \(self.file.keys.count) 条数据, 已翻译 \(self.tFile.keys.count), 待翻译 \(self.ttKeys.count)"
    }
    
    func startTranslate(progress: Progress?, complete: Complete?) {
        self.progressAction = progress
        self.completeAction = complete
        guard self.ttKeys.count > 0 else {
            complete?()
            return
        }
        self.translate()
    }
    
    private func translate() {
        for i in 0..<concurrentCount {
            currentIndex = transProgress * concurrentCount + i
            print(currentIndex)
            guard currentIndex < ttKeys.count else {
                currentIndex -= 1
                break
            }
            let key = ttKeys[currentIndex]
            guard tFile.dic[key] == nil else {
                continue
            }
            self.translate(key: key, content: file.dic[key]!)
        }
        print("🌛 translate 检查是否结束")
        checkCompleted()
    }
    
    private func translate(key: String, content: String) {
        Translator.translate(content: content, language: language) { [unowned self] result in
            if let result = result {
                //去除引号， 防止错误
                self.tFile.dic[key] = result.replacingOccurrences(of: "\"", with: "")
            } else {
                self.tFile.dic[key] = "⚠️⚠️⚠️ Translate Failed ⚠️⚠️⚠️"
            }
            print("☀️ translate 检查是否结束")
            self.checkCompleted()
        }
    }
    
    private func checkCompleted() {
        let translatedCount = tFile.dic.count - tFile.keys.count
        if ttKeys.count == translatedCount {
            completeAction?()
        } else {
            self.progressAction?(translatedCount, ttKeys.count)
            self.checkProgress()
        }
    }
    
    private func checkProgress() {
        if (currentIndex + 1)%concurrentCount == 0 {
            transProgress += 1
            translate()
        }
    }
    
    func saveTranslatedFile() {
        tFile.save()
    }
    
    func successDescription() -> String {
        var desc = "翻译完成 🎉🎉🎉\n总共翻译 \(ttKeys.count) 条"
        desc += "\n文件已保存到\n\(tFile.path ?? "")"
        return desc
    }
}