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
    case minutes(TimeInterval)
    case hours(TimeInterval)
    case days(TimeInterval)
    case months(TimeInterval)
    case date(Date)
    
    var expirationDate: Date {
        switch self {
        case .never:
            return Date.distantFuture
        case .seconds(let seconds):
            return Date().addingTimeInterval(seconds)
        case .minutes(let minutes):
            return Date().addingTimeInterval(60 * minutes)
        case .hours(let hours):
            return Date().addingTimeInterval(60 * 60 * hours)
        case .days(let days):
            return Date().addingTimeInterval(60 * 60 * 24 * days)
        case .months(let months):
            return Date().addingTimeInterval(60 * 60 * 24 * 30 * months)
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
