//
//  Cache.swift
//  Cache
//
//  Created by Christian Bator on 8/28/16.
//  Copyright © 2016 jcbator. All rights reserved.
//

import Foundation

public enum CacheError: Error {
    
    case dataConversionFailed
    
    var reason: String {
        switch self {
        case .dataConversionFailed:
            return "Converting the dataConvertible to Data failed"
        }
    }
}

private let domainIdentifier = "com.jcbator.cache"

public class Cache<T: DataConvertible> {
    
    public let name: String
    public let cacheDirectory: URL

    private let _cache = NSCache<AnyObject, AnyObject>()
    private let _fileManager = FileManager()
    
    private var _allKeys: [String]?

    public init?(name: String, directory: URL?, fileProtection: String? = nil) {
        self.name = name
        _cache.name = name
        
        if let directory = directory {
            cacheDirectory = directory
        }
        else {
            let url = _fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            cacheDirectory = url.appendingPathComponent(domainIdentifier + "/" + name)
        }

        do {
            try _fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)

            if let fileProtection = fileProtection {
                let protection = [FileAttributeKey.protectionKey : fileProtection]
                try _fileManager.setAttributes(protection, ofItemAtPath: cacheDirectory.path)
            }
        }
        catch {
            debugPrint(error)
            
            return nil
        }
    }

    public convenience init?(name: String) {
        self.init(name: name, directory: nil)
    }
    
    public subscript(key: String) -> T? {
        get {
            return value(forKey: key)
        }
        
        set(newValue) {
            if let value = newValue {
                set(value, forKey: key)
            }
            else {
                removeValueForKey(key)
            }
        }
    }
    
    // MARK: - Reading

    public func value(forKey key: String, allowingExpiredResult: Bool = false) -> T? {
        if let validValue = _read(key), (!validValue.expired || allowingExpiredResult) {
            return validValue.value
        }
        
        return nil
    }
    
    public func allKeys() -> [String] {
        if let allKeys = _allKeys {
            return allKeys
        }
        
        let urls = try? _fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [])
        let refreshedKeys: [String] = urls?.flatMap { $0.deletingPathExtension().lastPathComponent } ?? []
        
        _allKeys = refreshedKeys
        
        return refreshedKeys
    }

    public func allValues(_ allowingExpiredResults: Bool = false) -> [T] {
        let keys = allKeys()
        
        let results = keys.flatMap { self._read($0) }
        let filtered = allowingExpiredResults ? results : results.filter { !$0.expired }
            
        let values = filtered.flatMap { $0.value }
        
        return values
    }
    
    // MARK: - Writing
    
    public func set(_ value: T, forKey key: String, expiration: Expiration = .never) {
        let cacheable = Cacheable(value: value, expirationDate: expiration.expirationDate)
        _write(cacheable, forKey: key)
    }
    
    // MARK: - Removing

    public func removeValueForKey(_ key: String) {
        _allKeys = nil
            
        _cache.removeObject(forKey: NSString(string: key))
            
        let url = _urlForKey(key)
        
        do {
            try _fileManager.removeItem(at: url)
        }
        catch {
            debugPrint(error)
        }
    }
    
    public func removeExpiredValues() {
        allKeys().forEach { key in
            if let value = _read(key), value.expired {
                removeValueForKey(key)
            }
        }
    }

    public func removeAllValues() {
        allKeys().forEach(removeValueForKey)
    }
    
    // MARK: - Helpers
    
    private func _read(_ key: String) -> Cacheable<T>? {
        if let memoryCacheable = _cache.object(forKey: NSString(string: key)) as? Cacheable<T> {
            return memoryCacheable
        }
        
        let path = _urlForKey(key).path
        
        if  _fileManager.fileExists(atPath: path),
            let data = _fileManager.contents(atPath: path),
            let diskCacheable = Cacheable<T>(data: data) {
            
            _cache.setObject(diskCacheable as AnyObject, forKey: NSString(string: key))
            
            return diskCacheable
        }
        
        return nil
    }

    private func _write(_ cacheable: Cacheable<T>, forKey key: String) {
        _allKeys = nil
        
        _cache.setObject(cacheable as AnyObject, forKey: NSString(string: key))
        
        let url = self._urlForKey(key)
        
        do {
           try cacheable.asData().write(to: url, options: .atomic)
        }
        catch {
            debugPrint(error)
        }
    }
    
    private func _urlForKey(_ key: String) -> URL {
        let sanitizedKey = _sanitize(key)
        let url = cacheDirectory.appendingPathComponent(sanitizedKey)
        
        return url
    }
    
    private func _sanitize(_ key: String) -> String {
        return key.replacingOccurrences(of: "[^a-zA-Z0-9_]+", with: "-", options: .regularExpression, range: nil)
    }
    
    // MARK: - Testing Helpers
    
    internal func _removeFromMemory(_ key: String) {
        _cache.removeObject(forKey: NSString(string: key))
    }
}

public struct CacheCleaner {
    
    public static func purgeAll() {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cacheDirectory = url.appendingPathComponent(domainIdentifier)
        
        do {
            try FileManager.default.removeItem(at: cacheDirectory)
        }
        catch {
            debugPrint(error)
        }
    }
}
