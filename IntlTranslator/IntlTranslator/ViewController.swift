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

    var transProgress: Int = 0
    
    private var data = DataCenter()
    
    ///翻译并发数量
    var concurrentCount: Int = 100
    
    var parser: StringsParser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didSelectLanguage(_ sender: NSComboBox) {
        print(sender.stringValue)
        self.label.stringValue = "等待翻译"
    }
    
    func reset() {
        self.parser = nil
        self.data = DataCenter()
        transProgress = 0
        self.label.stringValue = "正在启动翻译..."
    }

    @IBAction func transBtnDidClick(_ sender: NSButton) {
        
        reset()
        
        parser = StringsParser(path: pathField.stringValue)
        
        if let originalDic = parser?.parseString() {
            data.originalDic = originalDic
        }
        guard data.originalDic.count > 0 else {
            return
        }
        DispatchQueue.main.async {
            self.indicator.startAnimation(nil)
            self.label.stringValue = "检测到 \(self.data.transKeys.count) 条待翻译数据"
        }
        translate()
    }
    
    func translate() {
        
        for i in 0..<concurrentCount {
            let theIndex = transProgress * concurrentCount + i
            guard theIndex < data.transKeys.count else {
                break
            }
            let key = data.transKeys[theIndex]
            guard data.translatedDic[key] == nil else {
                continue
            }
            self.translate(key: key, content: data.originalDic[key]!)
        }
        
    }
    
    func translate(key: String, content: String) {
        Translator.translate(content: content, language: language.stringValue) { [unowned self] result in
            
            if let result = result {
                //去除引号， 防止错误
                self.data.translatedDic[key] = result.replacingOccurrences(of: "\"", with: "")
            } else {
                self.data.translatedDic[key] = "⚠️⚠️⚠️ Translate Failed ⚠️⚠️⚠️"
                self.data.errorArray.append(key)
            }
            
            DispatchQueue.main.async {
                self.label.stringValue = self.data.progressDescription()
            }
            
            self.checkCompleted()
            
            self.checkProgress()
        }
    }
    
    func checkCompleted() {
        if data.translateCompleted() {
            DispatchQueue.main.async {
                self.indicator.stopAnimation(nil)
            }
            successAction()
        }
    }
    
    func checkProgress() {
        if data.translatedDic.count%concurrentCount == 0 {
            transProgress += 1
            translate()
        }
    }
    
    func successAction() {
        DispatchQueue.main.async {
            self.label.stringValue = self.data.successDescription()
        }
        self.exportTranslatedFile()
    }
    
    func exportTranslatedFile() {
        guard let outputString = parser?.convertToString(dic: self.data.translatedDic) else {
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
    
    override var representedObject: Any? {
        didSet {
            
        }
    }
    
}

