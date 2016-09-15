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
    case date(Foundation.Date)
    
    var expirationDate: Foundation.Date {
        switch self {
        case .never:
            return Foundation.Date.distantFuture
        case .seconds(let seconds):
            return Foundation.Date().addingTimeInterval(seconds)
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
