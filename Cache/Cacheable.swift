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
    public let expirationDate: Date
    
    public var expired: Bool {
        return expirationDate.isInThePast
    }

    public init(value: T, expirationDate: Date) {
        self.value = value
        self.expirationDate = expirationDate
    }
    
}

extension Cacheable: Serializable {
    
    public init?(serialized: Serialized) {
        guard
            let serializedValue = serialized[valueKey] as? Serialized,
            let value = T(serialized: serializedValue),
            let serializedExpiration = serialized[expirationDateKey] as? TimeInterval else {
                
                return nil
        }
        
        self.value = value
        self.expirationDate =  Date(timeIntervalSince1970: serializedExpiration)
    }
    
    public func serialize() -> Serialized {
        
        let serialized: Serialized = [
            valueKey : value.serialize() as AnyObject,
            expirationDateKey : expirationDate.timeIntervalSince1970 as AnyObject
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
            if  let serializedString = aDecoder.decodeObject(forKey: valueKey) as? String,
                let serializedData = serializedString.data(using: String.Encoding.utf8),
                let serialized = try JSONSerialization.jsonObject(with: serializedData, options: .allowFragments) as? Serialized {
                
                self.serialized = serialized
            }
        }
        catch { }
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        guard let serialized = serialized else {
            return
        }
        
        do {
            let serializedData = try JSONSerialization.data(withJSONObject: serialized, options: .prettyPrinted)
            
            if let serializedString = String(data: serializedData, encoding: String.Encoding.utf8) {
                aCoder.encode(serializedString, forKey: valueKey)
            }
        }
        catch { }
    }
    
}


