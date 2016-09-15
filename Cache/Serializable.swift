//
//  Serializable.swift
//  Cache
//
//  Created by Christian Bator on 8/28/16.
//  Copyright © 2016 jcbator. All rights reserved.
//

import Foundation

public typealias Serialized = [String : AnyObject]

public protocol Serializable {
    
    init?(serialized: Serialized)
    func serialize() -> Serialized
    
}

public protocol CollectionSerializable {
    
    static func collection(_ serialized: [Serialized]) -> [Self]
    
}

public extension CollectionSerializable where Self: Serializable {
    
    public static func collection(_ serializedEntities: [Serialized]) -> [Self] {
    
        let collection = serializedEntities.flatMap { serializedEntity in
            Self(serialized: serializedEntity)
        }
        
        return collection
    }
    
}

