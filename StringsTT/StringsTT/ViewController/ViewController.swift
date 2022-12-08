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
    
    @IBOutlet weak var allActions: NSComboBox!
    @IBOutlet weak var transBtn: NSButton!
    
    private var vm = TransViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.maximumNumberOfLines = 10
    }
    
    @IBAction func didSelectAction(_ sender: NSComboBox) {
        pathField.stringValue = ""
        tPathField.stringValue = ""
        let action = sender.stringValue
        switch action {
        case "翻译":
            showTip("请指定待翻译和已翻译的 Strings 文件路径")
        case "导出":
            self.tPathField.stringValue = ".localized"
            showTip("请指定需要导出的代码路径，并确认是否是.localized\n点击确认找出目录下 *\(tPathField.stringValue) 并导出成 key = value; 的 String 文件到桌面")
        case "复制":
            showTip("请在 Kakashi.swift 代码里修改定制内容， 并指定工程路径和导出路径")
        case "混淆":
            showTip("请指定代码路径")
        default:
            break
        }
    }
    
    /// 点击确认按钮
    @IBAction func transBtnDidClick(_ sender: NSButton) {
        let action = allActions.stringValue
        switch action {
        case "翻译":
            translateStringFile()
        case "导出":
            self.findLocalAndExport()
        case "复制":
            self.kakashiAction()
        case "混淆":
            self.obfusecateMethod()
        default:
            showTip("请选择合适的操作！")
            break
        }
    }
    
    /// 选择了翻译目标语言
    @IBAction func didSelectLanguage(_ sender: NSComboBox) {
        guard allActions.stringValue == "翻译" else { return }
        showTip("等待翻译")
        vm.language = sender.stringValue
        parseFiles()
    }
    
    /// 点击了？按钮
    @IBAction func helpAction(_ sender: NSButton) {
        guard allActions.stringValue == "翻译" else { return }
        NSWorkspace.shared.open(URL(string: ITConstant.languageCodePath)!)
    }

    /// 点击检查
    @IBAction func parseFilePath(_ sender: Any) {
        guard allActions.stringValue == "翻译" else { return }
        reset()
        parseFiles()
    }
    
    /// 在label上展示文字tip
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


extension ViewController {
    
    /// 翻译StringFile
    func translateStringFile() {
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
    
    //以"开头, 以".localized结尾, 中间不包含 .localized 和 "
    private func localRegex(tail: String = ".localized") -> String {
        return "\"[^\(tail)][^\"]+\"\(tail)"
    }
    
    /// 查找某个文件夹下 "国际化".localized 文件并导出
    func findLocalAndExport() {
        let localFinder = LocalFinder()
        self.indicator.startAnimation(nil)
        localFinder.progress = YFProgress(progress: { string in
            self.showTip(string)
        }, complete: { value in
            self.showTip(value)
        })
        let regex = localRegex(tail: tPathField.stringValue)
        let res = localFinder.findAllMatches(regex: regex, in: pathField.stringValue, for: [".swift", ".m"])
        if res.count > 0 {
            var file = StringFile()
            res.forEach { key in
                let tKey = key.replacingOccurrences(of: tPathField.stringValue, with: "")
                let value = tKey.replacingOccurrences(of: "\"", with: "")
                file.dic[tKey] = value
            }
            file.save()
        }
        self.showTip("Strings文件已导出")
        self.indicator.stopAnimation(nil)
    }
    
    //TODO: 给一键复制工程做个单独的UI， 或者单独app
    func kakashiAction() {
        let kakashi = Kakashi(path: pathField.stringValue, targetPath: tPathField.stringValue)
        kakashi.ninjutsuCopyPaste()
    }
    
    // 混淆方法名
    func obfusecateMethod() {
        let mo = MethodObfuscate()
        let methods = mo.findAllMethods(at: self.pathField.stringValue)
        YFLog(methods)
        mo.obfuscateMethods()
    }
}
