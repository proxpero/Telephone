//
//  HttpMethod.swift
//  Placeholder
//
//  Created by Todd Olsen on 4/6/17.
//  Copyright © 2017 proxpero. All rights reserved.
//

public enum HttpMethod<Body> {
    case get
    case post(Body)
}

extension HttpMethod {
    public var type: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        }
    }
}

extension HttpMethod {

    /// If the method is a `post` then tranform the body of the post into an `A`
    /// If the method is a `get` then do nothing.
    public func map<A>(transform: (Body) -> A) -> HttpMethod<A> {
        switch self {
        case .get: return .get
        case .post(let body):
            return .post(transform(body))
        }
    }

}
