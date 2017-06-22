
import Foundation

extension URLRequest {
    /// Initialize a URLRequest with a `Resource`.
    fileprivate init<A>(resource: Resource<A>) {
        self.init(url: resource.url)
//        self.httpMethod = resource.method.method
//        if case .post(let data) = resource.method {
//            httpBody = data
//        }
    }
}

/// An `Error` type to describe bad states of a `Webservice`.
extension String: Error {}

/// A protocol intended to abstract `URLSession.shared` so that the
/// singleton can be mocked during tests.
public protocol NetworkEngine {
    typealias Handler = (Data?, URLResponse?, Error?) -> ()
    /// A function to request a `Resource` of `A` from the network.
    func request<A>(resource: Resource<A>, handler: @escaping Handler)
}

/// `NetworkEngine` conformance.
extension URLSession: NetworkEngine {
    /// Initiate a url request by initializing a `URLSessionDataTask` with a
    /// URLRequest based on `resource` and a completion handler, and then calling
    /// `resume` on the task.
    ///
    /// - Parameters:
    ///   - resource: A `Resource` of `A`.
    ///   - handler: A completion handler of type `NetworkEngine.Handler`.
    public func request<A>(resource: Resource<A>, handler: @escaping NetworkEngine.Handler) {
        let task = dataTask(with: URLRequest(resource: resource), completionHandler: handler)
        task.resume()
    }
}

// A class load the data associated with a url.
public final class Webservice {

    /// Shared instance of a `Webservice`.
    public static let shared = Webservice()

    // The `NetworkEngine` to use for making URLRequests, probably the 
    // URLSession.shared singleton, but possibly a mock during testing.
    private let engine: NetworkEngine

    /// Initialize a `Webservice` with an optional `NetworkEngine` which defaults
    /// to `URLSession.shared`. Using an alternate engine is useful for testing.
    public init(engine: NetworkEngine = URLSession.shared) {
        self.engine = engine
    }

    /// Loads a `Resource`. The completion handler is not necessarily called
    /// on the main queue.
    ///
    /// - Parameter resource: A `Resource` of `A`
    /// - Parameter completion: A completion handler of type `Result<A> -> ()` which is called when the network call returns a response.
    public func load<A>(_ resource: Resource<A>, completion: @escaping (Result<A>) -> ()) {
        engine.request(resource: resource) { (data, response, _) in
            let result: Result<A>
            let parsed = data.flatMap(resource.parse)
            result = Result(parsed, or: "Webservice Error")
            completion(result)
        }
    }
}
