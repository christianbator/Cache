//
//  IceCreamFlavor.swift
//  Cache
//
//  Created by Christian Bator on 8/29/16.
//  Copyright © 2016 jcbator. All rights reserved.
//

import Foundation
import Cache

struct IceCreamFlavor: Serializable, CollectionSerializable {
    
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    init?(serialized: Serialized) {
        guard let serializedName = serialized["name"] as? String else {
            return nil
        }
        
        self.name = serializedName
    }
    
    func serialize() -> Serialized {
        return [
            "name" : name
        ]
    }
    
}