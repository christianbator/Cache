//
//  Cacheable.swift
//  Cache
//
//  Created by Christian Bator on 8/28/16.
//  Copyright © 2016 jcbator. All rights reserved.
//

import Foundation

public struct CacheableValue<T: JSONSerializable>: JSONSerializable {
    
    public let value: JSONSerializable
    private let expirationDate: NSDate
    
    public var expired: Bool {
        return expirationDate.isInThePast
    }

    public init(value: T, expirationDate: NSDate) {
        self.value = value
        self.expirationDate = expirationDate
    }
    
    public init?(json: JSON) {
        guard
            let valueJSON = json["value"] as? JSON,
            let jsonValue = T(json: valueJSON),
            let jsonExpiration = json["expiration_date"] as? NSTimeInterval else {
                
            return nil
        }
        
        value = jsonValue
        expirationDate =  NSDate(timeIntervalSince1970: jsonExpiration)
    }
    
    public func toJSON() -> JSON {
        let json: JSON = [
            "value": value.toJSON(),
            "expiration_date" : expirationDate.timeIntervalSince1970
        ]

        return json
    }
    
}

@objc class CacheableObject: NSObject {
    var json: JSON?
    
    init(value: JSONSerializable) {
        json = value.toJSON()
    }

    required init(coder aDecoder: NSCoder) {
        do {
            
        if  let jsonString = aDecoder.decodeObjectForKey("json") as? String,
            let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding),
            let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments) as? JSON {
            
                self.json = json
            }
        }
        catch { }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        guard let json = json else {
            return
        }
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            
            if let jsonString = String(data: jsonData, encoding: NSUTF8StringEncoding) {
                aCoder.encodeObject(jsonString, forKey: "json")
            }
        }
        catch { }
    }
}


