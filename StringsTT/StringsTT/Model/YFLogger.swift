//
//  YFLogger.swift
//  StringsTT
//
//  Created by Even Lin on 2022/12/8.
//  Copyright © 2022 cn.evenlin. All rights reserved.
//

import Foundation

public func YFLog<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
#if DEBUG
//    guard enableYFLog else { return }
    let time = Date()
    let format = DateFormatter()
    format.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    let timeString = format.string(from: time)
    let finalString = "📔[\(timeString)] \((file as NSString).lastPathComponent)[\(line)].\(method)\n\(message)"
//    YFLogManager.saveLog(finalString)
    print(finalString)
#endif
}
