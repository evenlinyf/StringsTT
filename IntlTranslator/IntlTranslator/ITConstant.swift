//
//  ITConstant.swift
//  IntlTranslator
//
//  Created by EvenLin on 2022/3/28.
//

import Cocoa

struct ITConstant {
    static func apiPath(content: String, to: String) -> String {
        return String(format: apiPath, to, content)
    }
    static let languageCodePath = "https://api.fanyi.baidu.com/product/113"
}
