//
//  WebserviceTests.swift
//  Telephone
//
//  Created by Todd Olsen on 6/22/17.
//

import XCTest
@testable import Telephone

class WebserviceTests: XCTestCase {

    class NetworkEngineMock: NetworkEngine {

        let data: Data?
        let response: URLResponse?
        let error: Error?

        init(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
            self.data = data
            self.response = response
            self.error = error
        }

        func request<A>(resource: Resource<A>, handler: @escaping NetworkEngine.Handler) {
            handler(data, response, error)
        }
    }

    struct Item {
        let name: String?
        init(data: Data) {
            self.name = String.init(data: data, encoding: .utf8)
        }
    }

    func testLoad() {
        let data = "data".data(using: .utf8)!
        let engine = NetworkEngineMock(data: data)
        let ws = Webservice(engine: engine)
        let url = URL(string: "example.com/items/1")!
        let resource = Resource(url: url) { data in
            return Item(data: data)
        }
        let loaded = expectation(description: "loaded")
        ws.load(resource) { result in
            switch result {
            case .success(let item):
                XCTAssertNotNil(item.name)
                XCTAssertEqual(item.name, "data")
            case .error(let error):
                XCTFail("error: \(error)")
            }
            loaded.fulfill()
        }
        wait(for: [loaded], timeout: 1)
    }

}
