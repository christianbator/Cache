//
//  Cache.swift
//  Cache
//
//  Created by Christian Bator on 8/28/16.
//  Copyright © 2016 jcbator. All rights reserved.
//

import Foundation

private let domainIdentifier = "com.jcbator.cache"

public struct Cache<T: Serializable> {
    
    public let name: String
    public let cacheDirectory: NSURL

    private let cache = NSCache()
    private let fileManager = NSFileManager()
    private let queue = dispatch_queue_create("\(domainIdentifier).diskQueue", DISPATCH_QUEUE_CONCURRENT)

    public init?(name: String, directory: NSURL?, fileProtection: String? = nil) {
        self.name = name
        cache.name = name

        if let directory = directory {
            cacheDirectory = directory
        }
        else {
            let url = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
            cacheDirectory = url.URLByAppendingPathComponent(domainIdentifier + "/" + name)
        }

        do {
            try fileManager.createDirectoryAtURL(cacheDirectory, withIntermediateDirectories: true, attributes: nil)

            if let fileProtection = fileProtection {
                let protection = [NSFileProtectionKey : fileProtection]
                try fileManager.setAttributes(protection, ofItemAtPath: cacheDirectory.path!)
            }
        }
        catch {
            debugPrint(error)
            
            return nil
        }
    }

    public init?(name: String) {
        self.init(name: name, directory: nil)
    }
    
    
    // MARK: - Reading

    public func valueForKey(key: String, allowingExpiredResult: Bool = false) -> T? {
        var value: Cacheable<T>?
        
        dispatch_sync(queue) {
            value = self.read(key)
        }

        guard let validValue = value where !validValue.expired || allowingExpiredResult else {
            return nil
        }

        return validValue.value as? T
    }

    public func allValues(allowingExpiredResults: Bool = false) -> [T] {
        var values = [T]()

        dispatch_sync(queue) {
            let results = self.allKeys.flatMap { self.read($0) }
            let filtered = allowingExpiredResults ? results : results.filter { !$0.expired }
            
            values = filtered.flatMap { $0.value as? T }
        }

        return values
    }
    
    public subscript(key: String) -> T? {
        get {
            return valueForKey(key)
        }
        
        set(newValue) {
            if let value = newValue {
                setValue(value, forKey: key)
            }
            else {
                removeValueForKey(key)
            }
        }
    }
    
    private func read(key: String) -> Cacheable<T>? {
        if  let object = cache.objectForKey(key) as? CacheableObject,
            let serialized = object.serialized,
            let value = Cacheable<T>(serialized: serialized) {
            
            return value
        }
        
        if  let path = urlForKey(key).path where fileManager.fileExistsAtPath(path),
            let object = unarchiveObjectAtPath(path),
            let serialized = object.serialized,
            let value = Cacheable<T>(serialized: serialized) {
            
            cache.setObject(object, forKey: key)
            
            return value
        }
        
        return nil
    }
    
    private func unarchiveObjectAtPath(path: String) -> CacheableObject? {
        
        return NSKeyedUnarchiver.safelyUnarchiveObjectAtPath(path) as? CacheableObject
    }

    
    // MARK: - Writing
    
    public func setValue(value: T, forKey key: String, expiration: Expiration = .Never) {
        let cacheable = Cacheable(value: value, expirationDate: expiration.expirationDate)
        let cacheableObject = CacheableObject(serializable: cacheable)
        
        self.write(cacheableObject, forKey: key)
    }
    
    private func write(object: CacheableObject, forKey key: String) {
        cache.setObject(object, forKey: key)
        
        dispatch_barrier_async(queue) {
            if let path = self.urlForKey(key).path {
                let success = NSKeyedArchiver.archiveRootObject(object, toFile: path)
                
                if !success {
                    debugPrint("ERROR")
                }
            }
        }
    }
    
    
    // MARK: - Removing

    public func removeValueForKey(key: String) {
        cache.removeObjectForKey(key)

        dispatch_barrier_async(queue) {
            self.removeFromDisk(key)
        }
    }
    
    public func removeExpiredValues() {
        dispatch_barrier_sync(queue) {
            for key in self.allKeys {
                if let value = self.read(key) where value.expired {
                    self.removeValueForKey(key)
                }
            }
        }
    }

    public func removeAllValues() {
        cache.removeAllObjects()
        
        dispatch_barrier_async(queue) {
            self.allKeys.forEach(self.removeFromDisk)
        }
    }

    internal func removeFromDisk(key: String) {
        let url = self.urlForKey(key)
        _ = try? self.fileManager.removeItemAtURL(url)
    }
    
    
    // MARK: - Helpers

    private var allKeys : [String] {
        let urls = try? fileManager.contentsOfDirectoryAtURL(cacheDirectory, includingPropertiesForKeys: nil, options: [])
        return urls?.flatMap { $0.URLByDeletingPathExtension?.lastPathComponent } ?? []
    }

    private func urlForKey(key: String) -> NSURL {
        let sanitizedKey = sanitize(key)
        let url = cacheDirectory.URLByAppendingPathComponent(sanitizedKey).URLByAppendingPathExtension("cache")
        
        return url
    }

    private func sanitize(key: String) -> String {
        return key.stringByReplacingOccurrencesOfString("[^a-zA-Z0-9_]+", withString: "-", options: .RegularExpressionSearch, range: nil)
    }
    
    
    // MARK: - Testing Helpers
    
    public func __removeFromMemory(key: String) {
        cache.removeObjectForKey(key)
    }

}

public struct CacheCleaner {
    
    public static func purgeCache() {
        let url = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
        let cacheDirectory = url.URLByAppendingPathComponent(domainIdentifier)
        
        _ = try? NSFileManager.defaultManager().removeItemAtURL(cacheDirectory)
    }
    
}
