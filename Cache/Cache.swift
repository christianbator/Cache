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
    public let cacheDirectory: URL

    private let cache = NSCache<NSString, AnyObject>()
    private let fileManager = FileManager()
    private let queue = DispatchQueue(label: "\(domainIdentifier).diskQueue", attributes: .concurrent)

    public init?(name: String, directory: URL?, fileProtection: String? = nil) {
        self.name = name
        cache.name = name

        if let directory = directory {
            cacheDirectory = directory
        }
        else {
            let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            cacheDirectory = url.appendingPathComponent(domainIdentifier + "/" + name)
        }

        do {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)

            if let fileProtection = fileProtection {
                let protection = [FileAttributeKey.protectionKey : fileProtection]
                try fileManager.setAttributes(protection, ofItemAtPath: cacheDirectory.path)
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

    public func valueForKey(_ key: String, allowingExpiredResult: Bool = false) -> T? {
        var value: Cacheable<T>?
        
        queue.sync {
            value = self.read(key)
        }

        guard let validValue = value , !validValue.expired || allowingExpiredResult else {
            return nil
        }

        return validValue.value as? T
    }

    public func allValues(_ allowingExpiredResults: Bool = false) -> [T] {
        var values = [T]()

        queue.sync {
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
    
    private func read(_ key: String) -> Cacheable<T>? {
        if  let object = cache.object(forKey: key as NSString) as? CacheableObject,
            let serialized = object.serialized,
            let value = Cacheable<T>(serialized: serialized) {
            
            return value
        }
        
        let path = urlForKey(key).path
        
        if  fileManager.fileExists(atPath: path),
            let object = unarchiveObjectAtPath(path),
            let serialized = object.serialized,
            let value = Cacheable<T>(serialized: serialized) {
            
            cache.setObject(object, forKey: key as NSString)
            
            return value
        }
        
        return nil
    }
    
    private func unarchiveObjectAtPath(_ path: String) -> CacheableObject? {
        return NSKeyedUnarchiver.safelyUnarchiveObject(atPath: path) as? CacheableObject
    }

    
    // MARK: - Writing
    
    public func setValue(_ value: T, forKey key: String, expiration: Expiration = .never) {
        let cacheable = Cacheable(value: value, expirationDate: expiration.expirationDate)
        let cacheableObject = CacheableObject(serializable: cacheable)
        
        self.write(cacheableObject, forKey: key)
    }
    
    private func write(_ object: CacheableObject, forKey key: String) {
        cache.setObject(object, forKey: key as NSString)
        
        queue.async(flags: .barrier) {
            let path = self.urlForKey(key).path
            let success = NSKeyedArchiver.archiveRootObject(object, toFile: path)
            
            if !success {
                debugPrint("Error writing object:\(object.serialized) for key: \(key)")
            }
        }
    }
    
    
    // MARK: - Removing

    public func removeValueForKey(_ key: String) {
        cache.removeObject(forKey: key as NSString)

        queue.async(flags: .barrier) {
            self.removeFromDisk(key)
        }
    }
    
    public func removeExpiredValues() {
        queue.sync(flags: .barrier) {
            for key in self.allKeys {
                if let value = self.read(key), value.expired {
                    self.removeValueForKey(key)
                }
            }
        }
    }

    public func removeAllValues() {
        cache.removeAllObjects()
        
        queue.async(flags: .barrier) {
            self.allKeys.forEach(self.removeFromDisk)
        }
    }

    internal func removeFromDisk(_ key: String) {
        let url = self.urlForKey(key)
        _ = try? self.fileManager.removeItem(at: url)
    }
    
    
    // MARK: - Helpers

    private var allKeys : [String] {
        let urls = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [])
        return urls?.flatMap { $0.deletingPathExtension().lastPathComponent } ?? []
    }

    private func urlForKey(_ key: String) -> URL {
        let sanitizedKey = sanitize(key)
        let url = cacheDirectory.appendingPathComponent(sanitizedKey).appendingPathExtension("cache")
        
        return url
    }

    private func sanitize(_ key: String) -> String {
        return key.replacingOccurrences(of: "[^a-zA-Z0-9_]+", with: "-", options: .regularExpression, range: nil)
    }
    
    
    // MARK: - Testing Helpers
    
    internal func _removeFromMemory(_ key: String) {
        cache.removeObject(forKey: key as NSString)
    }

}

public struct CacheCleaner {
    
    public static func purgeCache() {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cacheDirectory = url.appendingPathComponent(domainIdentifier)
        
        _ = try? FileManager.default.removeItem(at: cacheDirectory)
    }
    
}
