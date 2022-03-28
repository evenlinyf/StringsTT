//
//  ViewController.swift
//  IntlTranslator
//
//  Created by EvenLin on 2022/3/28.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var pathField: NSTextField!
    
    @IBOutlet weak var label: NSTextField!
    
    @IBOutlet weak var language: NSComboBox!
    
    @IBOutlet weak var indicator: NSProgressIndicator!
    
    @IBOutlet weak var transBtn: NSButton!
    
    var originalDic: [String: String] = [:]
    
    var translatedDic: [String: String] = [:]
    
    var errorArray: [String] = []
    
    var parser: StringsParser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func exportTranslatedFile() {
        guard let outputString = parser?.convertToString(dic: self.translatedDic) else {
            return
        }
        
        if let outPath = parser?.outputPath(language: language.stringValue) {
            do {
                try File(path: outPath).write(contents: outputString)
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Error output path")
        }
        
    }
    
    @IBAction func didSelectLanguage(_ sender: NSComboBox) {
        print(sender.stringValue)
        self.label.stringValue = "等待翻译"
    }
    
    func reset() {
        self.parser = nil
        self.originalDic.removeAll()
        self.translatedDic.removeAll()
        errorArray.removeAll()
        self.label.stringValue = "等待翻译"
    }
    

    @IBAction func transBtnDidClick(_ sender: NSButton) {
        self.reset()
        
        self.parser = StringsParser(path: pathField.stringValue)
        if let originalDic = parser?.parseString() {
            self.originalDic = originalDic
        }
        guard originalDic.count > 0 else {
            return
        }
        
        for (key, value) in originalDic {
            guard translatedDic[key] == nil else {
                continue
            }
//            print("\(key) = \(value)")
            
            self.indicator.startAnimation(nil)
            self.translate(key: key, content: value)

        }
        
    }
    
    func translate(key: String, content: String) {
        Translator.translate(content: content, language: language.stringValue) { result in
            if let result = result {
                self.translatedDic[key] = result
            } else {
                self.translatedDic[key] = "⚠️⚠️⚠️ Translate Failed ⚠️⚠️⚠️"
                self.errorArray.append(key)
            }
            
            DispatchQueue.main.async {
                self.label.stringValue = "Translating \(self.translatedDic.count)/\(self.originalDic.count)"
                if self.translatedDic.count == self.originalDic.count {
                    self.indicator.stopAnimation(nil)
                    if self.errorArray.count > 0 {
                        self.label.stringValue = """
翻译结束
总共翻译 \(self.originalDic.count) 条
翻译失败 \(self.errorArray.count) 条
正在重试失败的翻译
"""
                        self.retryFailedTranslations()
                    } else {
                        self.successAction()
                    }
                }
            }
        }
    }
    
    func successAction() {
            self.label.stringValue = """
翻译结束 🎉🎉🎉
总共翻译 \(self.originalDic.count) 条
翻译失败 \(self.errorArray.count) 条
文件已导出到桌面
"""
            self.exportTranslatedFile()
    }
    
    func retryFailedTranslations() {
        print("🌏🌏🌏 重试失败的翻译 🌏🌏🌏")
        var count = 0
        
        var secondErrorArray: [String] = []
        
        for key in errorArray {
            guard let value = originalDic[key] else { continue }
            self.indicator.startAnimation(nil)
            Translator.translate(content: value, language: language.stringValue) { result in
                count += 1
                if let result = result {
                    self.translatedDic[key] = result
                } else {
                    secondErrorArray.append(key)
                    self.translatedDic[key] = "⚠️⚠️⚠️ Translate Failed ⚠️⚠️⚠️"
                }
                DispatchQueue.main.async {
                    self.label.stringValue = "Retry Translating \(count)/\(self.errorArray.count)"
                    if count == self.errorArray.count {
                        self.errorArray = secondErrorArray
                        self.indicator.stopAnimation(nil)
                        self.successAction()
                    }
                }
            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}

