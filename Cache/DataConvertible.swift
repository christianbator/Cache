//
//  DataConvertible.swift
//  Cache
//
//  Created by Christian Bator on 9/16/16.
//  Copyright © 2016 jcbator. All rights reserved.
//

import Foundation

/// Conform to this protocol in order to be cached
public protocol DataConvertible {
    init?(data: Data)
    func asData() throws -> Data
}

/// Convenience method for turning Data into [String : Any]?
///
/// Usage: guard let dictionary = T.dictionary(with: data) else { ... } (where T: DataConvertible)
public extension DataConvertible {
    
    public static func dictionary(with data: Data) -> [String : Any]? {
        guard
            let dictionaryObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let dictionary = dictionaryObject as? [String : Any] else {
                
                return nil
        }
        
        return dictionary
    }
}

/// Adds DataConvertible conformance to an Array
///
/// [Element: DataConvertible] -> [String] -> Data
/// Data -> [String] -> [Element: DataConvertible]
extension Array: DataConvertible {

    public init?(data: Data) {
        guard
            let DataConvertibleType = Element.self as? DataConvertible.Type,
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let strings = json as? [String] else {
                
                return nil
        }
        
        let elements = strings.flatMap { (string: String) -> Element? in
            guard
                let data = string.data(using: .utf8),
                let element = DataConvertibleType.init(data: data) as? Element else {
                    
                    return nil
            }
            
            return element
        }
        
        self.init(elements)
    }

    public func asData() throws -> Data {
        let strings = try flatMap { (element: Element) -> String? in
            guard let dataConvertible = element as? DataConvertible else {
                return nil
            }
            
            let data = try dataConvertible.asData()
            
            guard let string = String(data: data, encoding: .utf8) else {
                return nil
            }
            
            return string
        }
        
        let data = try JSONSerialization.data(withJSONObject: strings, options: .prettyPrinted)
        
        return data
    }
}
