//
//  NSDate+Expiration.swift
//  Cache
//
//  Created by Christian Bator on 8/28/16.
//  Copyright © 2016 jcbator. All rights reserved.
//

import Foundation

public enum Expiration {
    
    case never
    case seconds(TimeInterval)
    case date(Date)
    
    var expirationDate: Date {
        switch self {
        case .never:
            return Date.distantFuture
        case .seconds(let seconds):
            return Date().addingTimeInterval(seconds)
        case .date(let date):
            return date
        }
    }
    
}

extension Date {
    
    var isInThePast: Bool {
        return timeIntervalSinceNow < 0
    }
    
}
