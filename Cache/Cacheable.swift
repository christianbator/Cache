//
//  Cacheable.swift
//  Cache
//
//  Created by Christian Bator on 8/28/16.
//  Copyright © 2016 jcbator. All rights reserved.
//

import Foundation


/// Cacheable is a value, expirationDate pair that is read from / written to disk

struct Cacheable<T: DataConvertible> {
    
    let value: T
    let expirationDate: Date
    
    var expired: Bool {
        return expirationDate.isInThePast
    }

    init(value: T, expirationDate: Date) {
        self.value = value
        self.expirationDate = expirationDate
    }
    
}


// MARK: - Private

private enum CacheKeys: String {
    
    case value
    case expiration
    
}

extension Cacheable: DataConvertible {
    
    init?(data: Data) {
        guard
            let json = Cacheable.dictionary(with: data),
            let valueString = json[CacheKeys.value.rawValue] as? String,
            let valueData = valueString.data(using: .utf8),
            let value = T(data: valueData),
            let serializedExpiration = json[CacheKeys.expiration.rawValue] as? TimeInterval else {
                
                return nil
        }
        
        self.value = value
        self.expirationDate =  Date(timeIntervalSinceReferenceDate: serializedExpiration)
    }
    
    func asData() throws -> Data {
        var data = Data()
        
        do {
            let valueData = try value.asData()
            guard let valueString = String(data: valueData, encoding: .utf8) else {
                throw CacheError.dataConversionFailed
            }
            
            let json: [String : Any] = [
                CacheKeys.value.rawValue : valueString,
                CacheKeys.expiration.rawValue : expirationDate.timeIntervalSinceReferenceDate
            ]
            
            data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        }
        catch {
            throw CacheError.dataConversionFailed
        }
        
        return data
    }
    
}
