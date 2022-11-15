//
//  File.swift
//  StringsTT
//
//  Created by EvenLin on 2022/3/28.
//

import Foundation

struct File: Hashable {
    let path: String

    /// The name portion of the file's path.
    var name: String {
        (path as NSString).pathComponents.last ?? ""
    }

    /// Returns the disk contents of the file.
    func read() throws -> String {
        try String(contentsOfFile: path, encoding: .utf8)
    }

    /// Writes contents to the file.
    func write(contents: String) throws {
        try contents.write(toFile: path, atomically: false, encoding: .utf8)
    }
    
    /// modifiable contents
    var contents: String = ""
    
    /// write the modifiable contents to the file.
    func write() throws {
        try contents.write(toFile: path, atomically: false, encoding: .utf8)
    }
}
