//
//  FileFinder.swift
//  StringsTT
//
//  Created by EvenLin on 2022/3/31.
//

import Cocoa

struct FileFinder {
    static func paths(for fileType: String?, path: String) throws -> [String] {
        
        guard let fileType = fileType else {
            return []
        }
        
        guard FileManager.default.fileExists(atPath: path) else {
            return []
        }
        
        var subPaths: [String] = []
        do {
            subPaths = try FileManager.default.subpathsOfDirectory(atPath: path)
        } catch let error {
            throw error
        }
        subPaths = subPaths.filter{$0.hasSuffix(fileType) && $0.contains("/") == false}
        
        return subPaths.sorted()
    }
}
