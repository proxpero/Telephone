
import Foundation

/// A class to manage the caching of `Resource`s.
public final class Cache {

    // The private implementation of the cached memory.
    private var storage: FileStorage

    /// Initialize with a `FileStorage` object. Default is `FileStorage()`
    public init(storage: FileStorage = FileStorage()) {
        self.storage = storage
    }

    /// Try to load a resource of `A` from the cache,
    /// return `nil` if it is not there.
    public func load<A>(_ resource: Resource<A>) -> A? {
        let data = storage[resource.cacheKey]
        return data.flatMap(resource.parse)
    }

    /// Place the `data` of `resource` in the cache.
    public func save<A>(_ data: Data, for resource: Resource<A>) {
        storage[resource.cacheKey] = data
    }

    public func clear() {
        storage.clear()
    }
}

extension Resource {
    /// A unique key to act as an address for the resource in a cache.
    var cacheKey: String {
        return "cache." + url.absoluteString.md5
    }
}
