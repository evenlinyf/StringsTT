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
    
    @IBAction func didSelectLanguage(_ sender: NSComboBox) {
        print(sender.stringValue)
        self.label.stringValue = "等待翻译"
        parseFiles()
        vm.language = sender.stringValue
    }
    
    @IBAction func helpAction(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: ITConstant.languageCodePath)!)
    }

    @IBAction func parseFilePath(_ sender: Any) {
        parseFiles()
    }
    
    @IBAction func transBtnDidClick(_ sender: NSButton) {
        reset()
        self.vm.language = self.language.stringValue
        parseFiles()
        self.indicator.startAnimation(nil)
        self.vm.startTranslate { [weak self] progress, all in
            DispatchQueue.main.async {
                self?.label.stringValue = "Translating \(progress)/\(all)"
            }
        } complete: { [weak self] in
            DispatchQueue.main.async {
                self?.indicator.stopAnimation(nil)
                self?.label.stringValue = self?.vm.successDescription() ?? ""
            }
        }
    }
    
    func parseFiles() {
        vm.parseFiles(filePath: pathField.stringValue, tFilePath: tPathField.stringValue)
        DispatchQueue.main.async {
            self.label.stringValue = self.vm.fileStatusDesc()
        }
    }
    
    func reset() {
        vm = TransViewModel()
        self.label.stringValue = "等待翻译"
    }
    
    func findSubPaths(path: String) {
        do {
            let sub = try FileFinder.paths(for: ".lproj", path: path)
            print(sub)
        } catch let error {
            print(error)
        }
    }
    
    override var representedObject: Any? {
        didSet {
            
        }
    }
    
}

