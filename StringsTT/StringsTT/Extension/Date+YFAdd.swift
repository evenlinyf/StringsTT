//
//  Date+YFAdd.swift
//  StringsTT
//
//  Created by EvenLin on 2022/3/31.
//

import Cocoa

extension Date {
    func timeString(_ format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let dateString = formatter.string(from: self)
        return dateString
    }
}
