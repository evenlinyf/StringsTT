//
//  DataCenter.swift
//  IntlTranslator
//
//  Created by EvenLin on 2022/3/29.
//

import Cocoa

struct DataCenter {
    var originalDic: [String: String] = [:] {
        didSet {
            self.transKeys = (originalDic as NSDictionary).allKeys as! [String]
        }
    }
    var translatedDic: [String: String] = [:]
    private(set) var transKeys: [String] = []
    var errorArray: [String] = []
    
    func translateCompleted() -> Bool {
        return translatedDic.count == originalDic.count
    }
    
    func progressDescription() -> String {
        return "Translating \(translatedDic.count)/\(originalDic.count)"
    }
    
    func successDescription() -> String {
        var desc = "翻译成功 🎉🎉🎉\n总共翻译 \(originalDic.count) 条"
        if errorArray.count > 0 {
            desc += "\n失败 \(errorArray.count) 条"
        }
        desc += "\n文件已导出到桌面"
        return desc
    }
    
}
