
import Foundation

/// A type to encapsulate URL information.
public struct URLProvider {

    /// The scheme of the url.
    public let scheme: String

    /// The host of the url.
    public let host: String

    /// The base url given the scheme and the host.
    public let baseURL: URL

    /// Returns a url based on the scheme and the host. Will will crash if a
    /// a url cannot be constructed.
    public init(scheme: String = "https", host: String) {
        self.scheme = scheme
        self.host = host
        self.baseURL = {
            guard let url = URL(string: scheme + "://" + host) else {
                fatalError("Could not create base url from scheme: \(scheme) and host: \(host)")
            }
            return url
        }()
    }

}
