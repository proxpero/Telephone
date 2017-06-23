//
//  ResourceTests.swift
//  Telephone
//
//  Created by Todd Olsen on 6/22/17.
//

import XCTest
@testable import Telephone

class ResourceTests: XCTestCase {

    struct Item: Codable, Equatable {
        static func ==(lhs: Item, rhs: Item) -> Bool {
            return lhs.id == rhs.id && lhs.name == rhs.name
        }
        let id: Int
        let name: String
    }

    let expectation = Item(id: 42, name: "accusamus beatae ad facilis cum similique qui sunt")

    func testDecodableInit() {

        guard let url = Bundle(for: WebserviceTests.self).url(forResource: "TestItem", withExtension: "json") else {
            XCTFail("Could not generate URL.")
            fatalError()
        }
        let resource: Resource<Item> = Resource(url: url)
        let data = try? Data.init(contentsOf: resource.url)
        let item = data.flatMap(resource.parse)
        XCTAssertNotNil(item)
        XCTAssertEqual(item!, expectation)  
    }


}
