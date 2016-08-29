//
//  Cacheable.swift
//  Cache
//
//  Created by Christian Bator on 8/28/16.
//  Copyright © 2016 jcbator. All rights reserved.
//

import Foundation

private let valueKey = "value"
private let expirationDateKey = "expiration_date"

public struct Cacheable<T: Serializable> {
    
    public let value: Serializable
    public let expirationDate: NSDate
    
    public var expired: Bool {
        return expirationDate.isInThePast
    }

    public init(value: T, expirationDate: NSDate) {
        self.value = value
        self.expirationDate = expirationDate
    }
    
}

extension Cacheable: Serializable {
    
    public init?(serialized: Serialized) {
        guard
            let serializedValue = serialized[valueKey] as? Serialized,
            let value = T(serialized: serializedValue),
            let serializedExpiration = serialized[expirationDateKey] as? NSTimeInterval else {
                
                return nil
        }
        
        self.value = value
        self.expirationDate =  NSDate(timeIntervalSince1970: serializedExpiration)
    }
    
    public func serialize() -> Serialized {
        
        let serialized: Serialized = [
            valueKey : value.serialize(),
            expirationDateKey : expirationDate.timeIntervalSince1970
        ]
        
        return serialized
    }

}

@objc class CacheableObject: NSObject {
    
    var serialized: Serialized?
    
    init(serializable: Serializable) {
        serialized = serializable.serialize()
    }

    required init(coder aDecoder: NSCoder) {
        do {
            if  let serializedString = aDecoder.decodeObjectForKey(valueKey) as? String,
                let serializedData = serializedString.dataUsingEncoding(NSUTF8StringEncoding),
                let serialized = try NSJSONSerialization.JSONObjectWithData(serializedData, options: .AllowFragments) as? Serialized {
                
                self.serialized = serialized
            }
        }
        catch { }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        guard let serialized = serialized else {
            return
        }
        
        do {
            let serializedData = try NSJSONSerialization.dataWithJSONObject(serialized, options: .PrettyPrinted)
            
            if let serializedString = String(data: serializedData, encoding: NSUTF8StringEncoding) {
                aCoder.encodeObject(serializedString, forKey: valueKey)
            }
        }
        catch { }
    }
    
}


