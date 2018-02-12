import Foundation

/// A representation of a resource on the internet, encapsulating the location
/// of the data, and how to parse the data into an `A`.
public struct Resource<A> {

    /// The URL of the resource.
    public let url: URL

    /// The HTTPMethod ('get', 'post', etc.)
    public let verb: HttpMethod<Data>

    /// A function to convert the received data to an `A`.
    public let parse: (Data) -> A?

    public init(url: URL, verb: HttpMethod<Data> = .get, parse: @escaping (Data) -> A?) {
        self.url = url
        self.verb = verb
        self.parse = parse
    }

}

extension Resource where A: Decodable {
    public init(url: URL, method: HttpMethod<Any> = .get) {
        self.url = url
        self.verb = method.map { json -> Data in
            // If `json` cannot be transformed into `Data` then it is a programmer
            // error and the app will crash. Check that the json was formed correctly.
            let result = try! JSONSerialization.data(withJSONObject: json, options: [])
            // swiftlint:disable:previous force_try
            return result
        }
        let decoder = JSONDecoder()
        self.parse = { data in
            return try? decoder.decode(A.self, from: data)
        }
    }
}
