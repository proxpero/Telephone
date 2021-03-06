//
//  md5Tests.swift
//  Telephone
//
//  Created by Todd Olsen on 6/22/17.
//

import XCTest
@testable import Telephone

class MD5Tests: XCTestCase {

    // RFC 1321 test suite
    let tests = [
        ("", "d41d8cd98f00b204e9800998ecf8427e"),
        ("a", "0cc175b9c0f1b6a831c399e269772661"),
        ("abc", "900150983cd24fb0d6963f7d28e17f72"),
        ("message digest", "f96b697d7cb7938d525a2f31aaf161d0"),
        ("abcdefghijklmnopqrstuvwxyz", "c3fcd3d76192e4007dfb496cca67e13b"),
        ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", "d174ab98d277d9f5a5611c2c9f419d9f"),
        ("12345678901234567890123456789012345678901234567890123456789012345678901234567890", "57edf4a22be3c955ac49da2e2107b67a") // swiftlint:disable:this line_length
    ]

    func testMD5() {

        for (value, hash) in tests {
            XCTAssertEqual(value.md5, hash)
        }

    }

}
