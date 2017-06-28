/// A type to represent either a success with an associated value of `A`,
/// or a failure, with an associated type of `Error`.
public enum Result<A> {
    case success(A)
    case error(Error)
}

extension Result {

    public init(_ value: A?, or error: Error) {
        if let value = value {
            self = .success(value)
        } else {
            self = .error(error)
        }
    }

    public var value: A? {
        guard case .success(let v) = self else { return nil }
        return v
    }
}
