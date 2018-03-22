# Cache
A simple Swift cache for fun and profit

![Swift](https://img.shields.io/badge/Swift-4.0-orange.svg)
![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)

## Usage

Cacheable values must conform to the `Serializable` protocol

```swift
import Cache

struct IceCreamFlavor {
    let name: String
    
    init(name: String) {
        self.name = name
    }
}

extension IceCreamFlavor: Serializable {
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
```

### Writing
```swift
let vanilla = IceCreamFlavor(name: "Vanilla")

let cache = Cache<IceCreamFlavor>(name: "Ice Cream Flavors")

cache?.setValue(vanilla, forKey: "vanilla") // Basic caching
cache?["vanilla"] = vanilla // Subscript caching

cache?.removeValueForKey("vanilla") // Basic removal
cache?["vanilla"] = nil // Subscript removal
```

### Reading
```swift
let cachedVanilla = cache.valueForKey("vanilla") // Basic reading
let cachedVanilla = cache["vanilla"] // Subscript reading
```

### Expiration

Cacheable values can expire given a relative or absolute expiration date

```swift
cache.setValue(vanilla, forKey: "vanilla", expiration: .Never)
cache.setValue(vanilla, forKey: "vanilla", expiration: .Seconds(10)) // Relative
cache.setValue(vanilla, forKey: "vanilla", expiration: .Date(NSDate(timeIntervalSince1970: 1428364800))) // Absolute
```

Expired values are removed from the cache upon accessing, and you can periodically remove expired values
with `removeExpiredValues()` (perhaps in `applicationDidFinishLaunching...`)

You can optionally read expired values (provided they haven't been cleaned up by `removeExpiredValues()`)

```swift
let cachedVanilla = cache.valueForKey("vanilla", allowingExpiredResult: true)
```

### Threaded Access

Cache is fully thread-safe:

```swift
DispatchQueue.global(qos: .background).async {
    cache["vanilla"] = IceCreamFlavor(name: "Vanilla")
}
```

### Miscellaneous

You can initialize a `Cache` with an optional custom directory
```swift
let url = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
let directory = url.URLByAppendingPathComponent("sweet-cache")
        
let cache = Cache<IceCreamFlavor>(name: "Ice Cream Flavors", directory: directory)
```

You can also add optional file protection with `NSFileProtection` if you have sensitive `IceCreamFlavor`s 
```swift
let cache = Cache<IceCreamFlavor>(name: "Ice Cream Flavors", directory: directory, fileProtection: NSFileProtectionComplete)
```

Other fun methods
```swift
let allValidIceCreamFlavors = cache.allValues()
let allIceCreamFlavors = cache.allValues(allowingExpiredResults: true)

cache?.removeAllValues() // Removes all values from a given cache with a name
CacheCleaner.purgeAll() // Removes all caches everywhere forever. Careful.
```

## Installation

#### Carthage

Add the following line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

```
github "christianbator/Cache"
```

Then run 
```
carthage update --platform iOS
```


## Tests

Open the Xcode project and press `⌘-U` to run the tests.
