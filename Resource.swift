
import Foundation

/// A representation of a resource on the internet, encapsulating the location
/// of the data, and how to parse the data into an `A`.
/// (For simplicity in the task at hand, this implementation understands GET 
/// requests only.)
public struct Resource<A> {

    /// The URL of the resource.
    public let url: URL

    /// A function to convert the received data to an `A`.
    public let parse: (Data) -> A?

}

extension Resource {

    /// Initialize a `Resource` specifically expecting JSON
    public init(url: URL, parseJSON: @escaping (Any) -> A?) {
        self.url = url
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            return json.flatMap(parseJSON)
        }
    }
    
}
