//
//  StringsParser.swift
//  IntlTranslator
//
//  Created by EvenLin on 2022/3/28.
//

import Cocoa

struct StringsParser {
    
    static func convertToString(dic: [String: String]?) -> String? {
        guard let dic = dic else {
            return nil
        }
        let sortedDict = dic.map { ($0.key, $0.value) }.sorted(by: <)
        
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let dateString = formatter.string(from: today)
        
        let fileString = """
        /*
          Localizable.strings
          Intl Translator

          Created by EvenLin on \(dateString)
          
        */
        
        """ + sortedDict.reduce("") {
            $0 + "\n\($1.0) = \"\($1.1)\";"
        }
        print(fileString)
        return fileString
    }
    
    static func convertToDic(string: String) -> [String: String] {
        let eachKeyValues = string.components(separatedBy: "\n").filter({$0.contains("=")})
        var map: [String: String] = [:]
        for keyValue in eachKeyValues {
            let kvArray = keyValue.components(separatedBy: "=")
            if kvArray.count == 2 {
                var key = kvArray[0]
                //去除后面的空格
                while key.hasSuffix(" ") {
                    key.removeLast()
                }
                var value = kvArray[1]
                //去除前面的空格
                while value.hasPrefix(" ") {
                    value.removeFirst()
                }
                if value.hasPrefix("\"") {
                    value.removeFirst()
                }
                value = value.replacingOccurrences(of: "\";", with: "")
                map[key] = value
            }
        }
        return map
    }
    
    static func outputPath(language: String) -> String {
        let deskTopPath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        
        let path = deskTopPath.appendingPathComponent("\(language)-Localizable.strings", isDirectory: false)
        
        if FileManager.default.fileExists(atPath: path.path) == false {
            FileManager.default.createFile(atPath: path.path, contents: nil)
        }
        return path.path
    }
    
}
