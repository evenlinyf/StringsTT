//
//  ViewController.swift
//  StringsTT
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
    private var ttKeys: [String] = []
    
    /// 翻译并发数量（循环请求翻译接口次数）
    private var concurrentCount: Int = 100
    /// 第几个一百个
    private var transProgress: Int = 0
    /// 当前翻译第几个
    private var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.maximumNumberOfLines = 10
    }
    
    @IBAction func didSelectLanguage(_ sender: NSComboBox) {
        print(sender.stringValue)
        self.label.stringValue = "等待翻译"
        parseFiles()
    }
    
    @IBAction func helpAction(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: ITConstant.languageCodePath)!)
    }

    @IBAction func parseFilePath(_ sender: Any) {
        self.parseFiles()
    }
    
    func findSubPaths() {
        do {
            let sub = try FileFinder.paths(for: ".lproj", path: pathField.stringValue)
            print(sub)
        } catch let error {
            print(error)
        }
    }
    
    @IBAction func transBtnDidClick(_ sender: NSButton) {
        
        reset()
        
        parseFiles()
        
        self.indicator.startAnimation(nil)
        translate()
    }
    
    func parseFiles() {
        file.path = pathField.stringValue
        if FileManager.default.fileExists(atPath: tPathField.stringValue) {
            tFile.path = tPathField.stringValue
        }
        
        guard file.dic.count > 0 else {
            return
        }
        
        ttKeys = file.keys.filter{tFile.keys.contains($0) == false}
        
        DispatchQueue.main.async {
            self.label.stringValue = "检测到 \(self.file.keys.count) 条数据, 已翻译 \(self.tFile.keys.count), 待翻译 \(self.ttKeys.count)"
        }
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
    
    func translate(key: String, content: String) {
        Translator.translate(content: content, language: language.stringValue) { [unowned self] result in
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
    
    func successDescription() -> String {
        var desc = "翻译完成 🎉🎉🎉\n总共翻译 \(ttKeys.count) 条"
        desc += "\n文件已保存到\n\(tFile.path ?? "")"
        return desc
    }
    
    func checkCompleted() {
        let translatedCount = tFile.dic.count - tFile.keys.count
        if ttKeys.count == translatedCount {
            DispatchQueue.main.async {
                self.indicator.stopAnimation(nil)
            }
            successAction()
        } else {
            DispatchQueue.main.async {
                self.label.stringValue = "Translating \(translatedCount)/\(self.ttKeys.count)"
            }
            self.checkProgress()
        }
    }
    
    func checkProgress() {
        if (currentIndex + 1)%concurrentCount == 0 {
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

