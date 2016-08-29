//
//  CacheTests.swift
//  CacheTests
//
//  Created by Christian Bator on 8/29/16.
//  Copyright © 2016 jcbator. All rights reserved.
//

import XCTest
import Cache

class CacheTests: XCTestCase {
    
    var cache: Cache<IceCreamFlavor>!
    
    override func setUp() {
        super.setUp()
        
        guard let cache = Cache<IceCreamFlavor>(name: "Ice Cream Flavors") else {
            assert(false, "Ice Cream Flavor cache failed to initialize")
        }
        
        self.cache = cache
    }
    
    override func tearDown() {
        super.tearDown()
        
        CacheCleaner.purgeCache()
    }
    
    func testVanillaAndChocolateCacheAndRead() {
        
        let vanilla = IceCreamFlavor(name: "Vanilla")
        let chocolate = IceCreamFlavor(name: "Chocolate")
        
        cache[vanilla.name] = vanilla
        cache[chocolate.name] = chocolate
        
        cache.__removeFromMemory(vanilla.name)
        cache.__removeFromMemory(chocolate.name)
        
        let cachedVanilla = cache[vanilla.name]
        let cachedChocolate = cache[chocolate.name]
        
        assert(cachedVanilla != nil && cachedVanilla?.name == "Vanilla", "Couldn't find Vanilla in the cache")
        assert(cachedChocolate != nil && cachedChocolate?.name == "Chocolate", "Couldn't find Chocolate in the cache")
    }
    
}
