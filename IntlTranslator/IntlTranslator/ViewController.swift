//
//  ViewController.swift
//  IntlTranslator
//
//  Created by EvenLin on 2022/3/28.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var pathField: NSTextField!
    
    @IBOutlet weak var tPathField: NSTextField!
    
    @IBOutlet weak var label: NSTextField!
    
    @IBOutlet weak var language: NSComboBox!
    
    @IBOutlet weak var indicator: NSProgressIndicator!
    
    @IBOutlet weak var transBtn: NSButton!
    
    
    private var file = StringFile()
    private var tFile = StringFile()
    
    /// 翻译并发数量（循环请求翻译接口次数）
    private var concurrentCount: Int = 100
    /// 第几个一百个
    private var transProgress: Int = 0
    /// 当前翻译第几个
    private var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didSelectLanguage(_ sender: NSComboBox) {
        print(sender.stringValue)
        self.label.stringValue = "等待翻译"
    }
    
    @IBAction func helpAction(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: ITConstant.languageCodePath)!)
    }

    @IBAction func transBtnDidClick(_ sender: NSButton) {
        
        reset()
        
        file.path = pathField.stringValue
        if FileManager.default.fileExists(atPath: tPathField.stringValue) {
            tFile.path = tPathField.stringValue
        } else {
            tFile.path = StringsParser.outputPath(language: language.stringValue)
        }
        
        guard file.dic.count > 0 else {
            return
        }
        
        DispatchQueue.main.async {
            self.indicator.startAnimation(nil)
            self.label.stringValue = "检测到 \(self.file.keys.count) 条未翻译数据, \(self.tFile.keys.count) 条已翻译数据"
        }
        translate()
    }
    
    func reset() {
        file = StringFile()
        tFile = StringFile()
        transProgress = 0
        self.label.stringValue = "等待翻译"
    }
    
    func translate() {
        
        for i in 0..<concurrentCount {
            currentIndex = transProgress * concurrentCount + i
            guard currentIndex < file.keys.count else {
                break
            }
            let key = file.keys[currentIndex]
            guard tFile.dic[key] == nil else {
                continue
            }
            self.translate(key: key, content: file.dic[key]!)
        }
        checkCompleted()
        
    }
    
    func translate(key: String, content: String) {
        Translator.translate(content: content, language: language.stringValue) { [unowned self] result in
            
            if let result = result {
                //去除引号， 防止错误
                self.tFile.dic[key] = result.replacingOccurrences(of: "\"", with: "")
            } else {
                self.tFile.dic[key] = "⚠️⚠️⚠️ Translate Failed ⚠️⚠️⚠️"
            }
            
            self.checkCompleted()
        }
    }
    
    func successDescription() -> String {
        var desc = "翻译成功 🎉🎉🎉\n总共翻译 \(file.keys.count) 条"
//        if errorArray.count > 0 {
//            desc += "\n失败 \(errorArray.count) 条"
//        }
        desc += "\n文件已保存到\(tFile.path ?? "")"
        return desc
    }
    
    func checkCompleted() {
        if file.dic.count == tFile.dic.count {
            DispatchQueue.main.async {
                self.indicator.stopAnimation(nil)
            }
            successAction()
        } else {
            DispatchQueue.main.async {
                self.label.stringValue = "Translating \(self.tFile.dic.count)/\(self.file.dic.count)"
            }
            self.checkProgress()
        }
    }
    
    func checkProgress() {
        if currentIndex%concurrentCount == 0 {
            transProgress += 1
            translate()
        }
    }
    
    func successAction() {
        DispatchQueue.main.async {
            self.label.stringValue = self.successDescription()
        }
        tFile.save()
    }
    
    override var representedObject: Any? {
        didSet {
            
        }
    }
    
}

