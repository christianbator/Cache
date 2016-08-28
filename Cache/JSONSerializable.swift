//
//  JSONSerializable.swift
//  Cache
//
//  Created by Christian Bator on 8/28/16.
//  Copyright © 2016 jcbator. All rights reserved.
//

import Foundation

public typealias JSON = [String : AnyObject]

public protocol JSONSerializable {
    
    init?(json: JSON)
    func toJSON() -> JSON
    
}
