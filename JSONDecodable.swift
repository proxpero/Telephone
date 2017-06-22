
/// A JSON dictionary.
public typealias JSONDictionary = [String: AnyObject]

/// Describes a type that can create itself out of a JSON dictionary.
protocol JSONDecodable {
    /// Initialize `Self` with a JSON dictionary.
    init?(json: JSONDictionary)
}

