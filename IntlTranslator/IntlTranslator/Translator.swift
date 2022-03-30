//
//  Translator.swift
//  IntlTranslator
//
//  Created by EvenLin on 2022/3/28.
//

import Cocoa

struct Translator {
    
    typealias TComplete = (String?) -> Void
    
    static func translate(content: String, language: String, complete: @escaping TComplete) {
        let path = ITConstant.apiPath(content: content, to: language).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let path = path else {
            complete(nil)
            return
        }
        guard let pathUrl = URL(string: path) else {
            complete(nil)
            return
        }
        let req = URLRequest(url: pathUrl)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: req) { data, resp, error in
            guard let data = data else {
                complete(nil)
                return
            }
            if let respDic = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                guard let isSuccess = respDic["success"] as? Bool else {
                    complete(nil)
                    return
                }
                guard isSuccess else {
                    complete(nil)
                    return
                }
                if let translatedString = respDic["data"] as? String {
                    complete(translatedString)
                    print("🌏 \(content) ---> \(translatedString)")
                } else {
                    complete(nil)
                }
            } else {
                print("转换失败")
                complete(nil)
            }
        }
        task.resume()
    }
}
