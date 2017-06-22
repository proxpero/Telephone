
import Foundation

/// A class to manage the interaction between a `Webservice` and a `Cache`.
public final class CachedWebservice {

    /// Shared instance (singleton) of a CachedWebservice (which uses `Webservice.shared`).
    public static let shared = CachedWebservice(Webservice.shared)

    private let webservice: Webservice
    private let cache: Cache

    /// Initialize `CachedWebservice` with a `Webservice` and a `Cache`
    public init(_ webservice: Webservice, cache: Cache = Cache()) {
        self.webservice = webservice
        self.cache = cache
    }

    /// Load a resource, if the response has been cached, call it with the 
    /// completion handler. Otherwise, load the response from the network,
    /// cache it, then call it with the completion handler.
    public func load<A>(_ resource: Resource<A>, completion: @escaping (Result<A>) -> ()) {

        if let result = cache.load(resource) {
            completion(.success(result))
            return
        }

        let dataResource = Resource<Data>(url: resource.url, parse: { $0 })

        webservice.load(dataResource) { result in
            switch result {
            case .success(let data):
                self.cache.save(data, for: resource)
                completion(Result(resource.parse(data), or: "Caching Error"))
            case .error(let error):
                completion(.error(error))
            }
        }
    }

}
