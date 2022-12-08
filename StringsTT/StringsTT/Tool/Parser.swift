//
//  Parser.swift
//  StringsTT
//
//  Created by EvenLin on 2022/3/28.
//

import Cocoa

struct Parser {
    
    static func convertToString(dic: [String: String]?) -> String? {
        guard let dic = dic else {
            return nil
        }
        let sortedDict = dic.map { ($0.key, $0.value) }.sorted(by: <)
        
        let dateString = Date().timeString("yyyy/MM/dd")
        
        let fileString = """
        /*
          Localizable.strings
          StringsTT

          Created by EvenLin on \(dateString)
          
        */
        
        """ + sortedDict.reduce("") {
            $0 + "\n\($1.0) = \"\($1.1)\";"
        }
//        YFLog(fileString)
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
    
    static func outputPath(prefix: String, dir: FileManager.SearchPathDirectory = .desktopDirectory) -> String {
        let deskTopPath = FileManager.default.urls(for: dir, in: .userDomainMask)[0]
        
        let path = deskTopPath.appendingPathComponent("\(prefix)-Localizable.strings", isDirectory: false)
        
        if FileManager.default.fileExists(atPath: path.path) == false {
            FileManager.default.createFile(atPath: path.path, contents: nil)
        }
        return path.path
    }
    
}
