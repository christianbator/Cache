//
//  NSDate+Expiration.swift
//  Cache
//
//  Created by Christian Bator on 8/28/16.
//  Copyright © 2016 jcbator. All rights reserved.
//

import Foundation

public enum Expiration {
    
    case Never
    case Seconds(NSTimeInterval)
    case Date(NSDate)
    
    var expirationDate: NSDate {
        switch self {
        case Never:
            return NSDate.distantFuture()
        case Seconds(let seconds):
            return NSDate().dateByAddingTimeInterval(seconds)
        case Date(let date):
            return date
        }
    }
    
}

extension NSDate {
    
    var isInThePast: Bool {
        return timeIntervalSinceNow < 0
    }
    
}