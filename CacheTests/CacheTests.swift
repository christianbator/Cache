//
//  CacheTests.swift
//  CacheTests
//
//  Created by Christian Bator on 8/29/16.
//  Copyright © 2016 jcbator. All rights reserved.
//

import XCTest
@testable import Cache

class CacheTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        CacheCleaner.purgeCache()
        super.tearDown()
    }
    
    func testVanillaAndChocolateCacheAndRead() {
        guard let cache = Cache<IceCreamFlavor>(name: "Ice Cream Flavors") else {
            assertionFailure("Ice Cream Flavor cache failed to initialize")
            return 
        }
        
        let vanilla = IceCreamFlavor(name: "Vanilla")
        let chocolate = IceCreamFlavor(name: "Chocolate")
        
        cache[vanilla.name] = vanilla
        cache[chocolate.name] = chocolate
        
        cache._removeFromMemory(vanilla.name)
        cache._removeFromMemory(chocolate.name)
        
        let cachedVanilla = cache[vanilla.name]
        let cachedChocolate = cache[chocolate.name]
        
        assert(cachedVanilla != nil && cachedVanilla?.name == "Vanilla", "Couldn't find Vanilla in the cache")
        assert(cachedChocolate != nil && cachedChocolate?.name == "Chocolate", "Couldn't find Chocolate in the cache")
    }
    
    func testVanillaAndChocolateAllKeys() {
        guard let cache = Cache<IceCreamFlavor>(name: "Ice Cream Flavors") else {
            assertionFailure("Ice Cream Flavor cache failed to initialize")
            return
        }
        
        let vanilla = IceCreamFlavor(name: "Vanilla")
        let chocolate = IceCreamFlavor(name: "Chocolate")
        
        cache[vanilla.name] = vanilla
        cache[chocolate.name] = chocolate
        
        let allKeys = cache.allKeys()
        
        
        
        assert(allKeys.contains("Vanilla"), "Couldn't find Vanilla key in the cache")
        assert(allKeys.contains("Chocolate"), "Couldn't find Chocolate key in the cache")
    }
    
    func testVanillaAndChocolateAllValues() {
        guard let cache = Cache<IceCreamFlavor>(name: "Ice Cream Flavors") else {
            assertionFailure("Ice Cream Flavor cache failed to initialize")
            return
        }
        
        let vanilla = IceCreamFlavor(name: "Vanilla")
        let chocolate = IceCreamFlavor(name: "Chocolate")
        
        cache[vanilla.name] = vanilla
        cache[chocolate.name] = chocolate
        
        let allValues = cache.allValues()
        
        assert(allValues.contains(vanilla), "Couldn't find Vanilla key in the cache")
        assert(allValues.contains(chocolate), "Couldn't find Chocolate key in the cache")
    }
    
    func testIceCreamCollection() {
        guard let cache = Cache<[IceCreamFlavor]>(name: "Ice Cream Flavor Collection") else {
            assertionFailure("Failed to initialize ice cream flavor collection cache")
            return
        }
        
        let vanilla = IceCreamFlavor(name: "Vanilla")
        let chocolate = IceCreamFlavor(name: "Chocolate")
        
        let collection = [vanilla, chocolate]
        
        cache.set(collection, forKey: "flavors")
        
        cache._removeFromMemory("flavors")
        
        guard let refreshedCollection = cache["flavors"] else {
            assertionFailure("Incorrect collection cache type")
            return
        }
        
        assert(refreshedCollection == collection, "Incorrect collection cache value")
    }
    
    func test1000WritesAndReads() {
        guard let cache = Cache<IceCreamFlavor>(name: "Big Ice Cream Flavor Cache") else {
            assertionFailure("Failed to initialize ice cream flavor collection cache")
            return
        }
        
        let value = IceCreamFlavor(name: "melting")
        
        var keys = [String]()
        for _ in 0..<1000 {
            keys.append(randomStringWithLength(len: 32))
        }
        
        measure() {
            for key in keys {
                cache.set(value, forKey: key)
            }
            
            for key in keys {
                let _ = cache.value(forKey: key)
            }
        }
    }
    
    func test1000WritesAndReadsBaseline() {
        let cache = NSCache<NSString, AnyObject>()
        cache.name = "big_cache"
        
        let value = IceCreamFlavor(name: "melting") as AnyObject
        
        var keys = [NSString]()
        for _ in 0..<1000 {
            keys.append(randomStringWithLength(len: 32) as NSString)
        }
        
        measure() {
            for key in keys {
                cache.setObject(value, forKey: key)
            }
            
            for key in keys {
                let _ = cache.object(forKey: key)
            }
        }
        
    }
    
    func randomStringWithLength(len: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let length: UInt32 = UInt32(letters.characters.count)
        
        var randomString = ""
        
        for _ in 0..<len {
            let rand = arc4random_uniform(length)
            let index = letters.index(letters.startIndex, offsetBy: String.IndexDistance(rand))
            randomString.append(letters[index])
        }
        
        return randomString
    }
    
}





