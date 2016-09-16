//
//  IceCreamFlavor.swift
//  Cache
//
//  Created by Christian Bator on 8/29/16.
//  Copyright © 2016 jcbator. All rights reserved.
//

import Foundation
import Cache

struct IceCreamFlavor: Entity, Equatable {
    
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    init?(data: Data) {
        guard
            let json = IceCreamFlavor.dictionary(with: data),
            let name = json["name"] as? String else {
                
                return nil
        }

        self.name = name
    }
    
    func asData() throws -> Data {
        let json = [
            "name" : name
        ]
        
        let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        return data
    }
    
}


func ==(lhs: IceCreamFlavor, rhs: IceCreamFlavor) -> Bool {
    return lhs.name == rhs.name
}
