import Foundation

/// A class to manage storing and retrieving data from disk.
public struct FileStorage {

    // The base URL.
    private let baseURL: URL

    /// Initialize with a baseURL, which has a default value of the document 
    /// directory in the user domain mask.
    public init(baseURL: URL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)) { // swiftlint:disable:this line_length
        // swiftlint:disable:previous force_try
        self.baseURL = baseURL
    }

    /// A subscript for reading and writing data at the address represented
    /// by `key`. Setting a value of `nil` clears the cache for that `key`.
    public subscript(key: String) -> Data? {
        get {
            let url = baseURL.appendingPathComponent(key)
            return try? Data(contentsOf: url)
        }
        set {
            let url = baseURL.appendingPathComponent(key)
            if let newValue = newValue {
                _ = try? newValue.write(to: url)
            } else {
                // If `newValue` is `nil` then clear the cache.
                _ = try? FileManager.default.removeItem(at: url)
            }
        }
    }

    public func clear() {
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: baseURL,
            includingPropertiesForKeys: [],
            options: FileManager.DirectoryEnumerationOptions(rawValue: 0)
            ) else { return }
        urls.forEach { url in
            _ = try? FileManager.default.removeItem(at: url)
        }

    }
}
