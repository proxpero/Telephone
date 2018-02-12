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

    struct Item: Codable, Equatable {
        static func == (lhs: Item, rhs: Item) -> Bool {
            return lhs.id == rhs.id && lhs.name == rhs.name
        }
        let id: Int // swiftlint:disable:this identifier_name
        let name: String
    }

    let expectation = Item(id: 42, name: "accusamus beatae ad facilis cum similique qui sunt")

    struct Foo: Codable {
        let name: String?
        init(data: Data) {
            self.name = String.init(data: data, encoding: .utf8)
        }
    }

    func testLoadFromMemeory() {
        let data = "data".data(using: .utf8)!
        let engine = NetworkEngineMock(data: data)
        let ws = Webservice(engine: engine)
        let url = URL(string: "example.com/items/1")!
        let resource = Resource(url: url, verb: .get) { data in
            return Foo(data: data)
        }
        let loaded = expectation(description: "loaded")
        ws.load(resource) { result in
            switch result {
            case .success(let foo):
                XCTAssertNotNil(foo.name)
                XCTAssertEqual(foo.name, "data")
            case .error(let error):
                XCTFail("error: \(error)")
            }
            loaded.fulfill()
        }
        wait(for: [loaded], timeout: 1)
    }

    func testLoadFromDisk() {

        guard let url = Bundle(for: WebserviceTests.self).url(forResource: "TestItem", withExtension: "json") else {
            XCTFail("Could not generate URL.")
            fatalError()
        }
        let data = try! Data(contentsOf: url) // swiftlint:disable:this force_try
        let engine = NetworkEngineMock(data: data)
        let resource = Resource<Item>(url: url)
        print(resource)
        let ws = Webservice(engine: engine)
        ws.load(resource) { result in
            switch result {
            case .success(let item):
                XCTAssertEqual(item, self.expectation)
            case .error(let error):
                XCTFail("\(error)")
            }
        }
    }
}
