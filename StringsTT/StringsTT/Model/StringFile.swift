//
//  StringFile.swift
//  StringsTT
//
//  Created by EvenLin on 2022/3/29.
//

import Cocoa

struct StringFile {
    
    var path: String? {
        didSet {
            parseFile()
        }
    }
    
    var dic : [String: String] = [:]
    
    private(set) var keys: [String] = []
    
    private mutating func parseFile() {
        guard let path = path else {
            return
        }
        
        guard FileManager.default.fileExists(atPath: path) else {
            print("文件不存在\(path)")
            return
        }
        let file = File(path: path)
        do {
            let mapString = try file.read()
            dic = Parser.convertToDic(string: mapString)
            keys = (dic as NSDictionary).allKeys as! [String]
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func save() {
        guard let outputString = Parser.convertToString(dic: dic) else {
            return
        }
        
        var outputPath = self.path ?? ""
        if outputPath.isEmpty {
            outputPath = Parser.outputPath(prefix: Date().timeString("yyyyMMddHHmm"))
        }
        
        do {
            try File(path: outputPath).write(contents: outputString)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
