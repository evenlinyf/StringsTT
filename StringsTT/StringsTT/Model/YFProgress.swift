//
//  YFProgress.swift
//  StringsTT
//
//  Created by Even Lin on 2022/12/8.
//  Copyright © 2022 cn.evenlin. All rights reserved.
//

import Foundation

public typealias CompleteV = () -> Void
public typealias CompleteB = (Bool) -> Void
public typealias CompleteS = (String?) -> Void
public typealias CompleteT<T> = (T) -> Void

struct YFProgress {
    
    var onComplete: CompleteS?
    var onProgress: CompleteS?
    
    init(progress: CompleteS?, complete: CompleteS?) {
        self.onProgress = progress
        self.onComplete = complete
    }
}
