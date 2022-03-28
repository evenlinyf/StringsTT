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
    
    func reset() {
        self.parser = nil
        self.originalDic.removeAll()
        self.translatedDic.removeAll()
        self.label.stringValue = "等待翻译"
    }
    

    @IBAction func transBtnDidClick(_ sender: NSButton) {
        print("clicked Button， language = \(language.stringValue), path = \(pathField.stringValue)")
        self.reset()
        self.parser = StringsParser(path: pathField.stringValue)
        if let originalDic = parser?.parseString() {
            self.originalDic = originalDic
        }
        guard originalDic.count > 0 else {
            return
        }
        translatedDic.removeAll()
        var index = 0
        var errorArray: [String] = []
        for (key, value) in originalDic {
            guard translatedDic[key] == nil else {
                continue
            }
            print("\(key) = \(value)")
            index += 1
            let curProgress = "\(index)/\(originalDic.count)"
            
            DispatchQueue.main.async {
                self.indicator.startAnimation(nil)
                self.label.stringValue = "\(curProgress) Translating \(value)"
            }
            
            Translator.translate(content: value, language: language.stringValue) { result in
                if let result = result {
                    self.translatedDic[key] = result
                } else {
                    self.translatedDic[key] = "⚠️⚠️⚠️ Translate Failed ⚠️⚠️⚠️"
                    errorArray.append(key)
                }
                DispatchQueue.main.async {
                    self.indicator.stopAnimation(nil)
                    if self.translatedDic.count == self.originalDic.count {
                        self.label.stringValue = """
翻译结束 🎉🎉🎉
总共翻译 \(self.originalDic.count) 条
翻译失败 \(errorArray.count) 条
文件已导出到桌面
"""
                        self.exportTranslatedFile()
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

