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
    
    private var vm = TransViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.maximumNumberOfLines = 10
    }
    
    /// 选择了翻译目标语言
    @IBAction func didSelectLanguage(_ sender: NSComboBox) {
        print(sender.stringValue)
        showTip("等待翻译")
        vm.language = sender.stringValue
        parseFiles()
    }
    
    /// 点击了？按钮
    @IBAction func helpAction(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: ITConstant.languageCodePath)!)
    }

    /// 点击检查
    @IBAction func parseFilePath(_ sender: Any) {
        reset()
        parseFiles()
    }
    
    /// 点击了查找并导出按钮
    @IBAction func findAndExport(_ sender: NSButton) {
        findLocalAndExport()
    }
    
    /// 查找某个文件夹下 "国际化".localized 文件并导出
    func findLocalAndExport() {
        let localFinder = LocalFinder()
        //以"开头, 以".local结尾, 中间不包含 .local 和 "
        let localStr = ".localized"
        let res = localFinder.findAllMatches(regex: "\"[^\(localStr)][^\"]+\"\(localStr)", in: pathField.stringValue, for: [".swift", ".m"])
        
        if res.count > 0 {
            var file = StringFile()
            res.forEach { key in
                let tKey = key.replacingOccurrences(of: localStr, with: "")
                let value = tKey.replacingOccurrences(of: "\"", with: "")
                file.dic[tKey] = value
            }
            file.save()
        }
    }
    
    /// 点击一键翻译按钮
    @IBAction func transBtnDidClick(_ sender: NSButton) {
        reset()
        parseFiles()
        self.indicator.startAnimation(nil)
        self.vm.startTranslate { [weak self] progress, all in
            self?.showTip("Translating \(progress)/\(all)")
        } complete: { [weak self] in
            DispatchQueue.main.async {
                self?.indicator.stopAnimation(nil)
            }
            self?.showTip(self?.vm.successDescription())
        }
    }
    
    /// 根据路径解析文件
    func parseFiles() {
        vm.parseFiles(filePath: pathField.stringValue, tFilePath: tPathField.stringValue)
        showTip(self.vm.fileStatusDesc())
    }
    
    
    /// 重置ViewModel
    func reset() {
        vm = TransViewModel()
        vm.language = self.language.stringValue
        showTip("等待翻译")
    }
    
    func showTip(_ tip: String?) {
        DispatchQueue.main.async {
            self.label.stringValue = tip ?? ""
        }
    }
    
    
    
    override var representedObject: Any? {
        didSet {
            
        }
    }
    
}

