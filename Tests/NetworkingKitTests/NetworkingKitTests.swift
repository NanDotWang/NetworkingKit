//
//  NetworkingKitTests.swift
//  NanTech
//
//  Created by Nan Wang on {TODAY}.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation
import XCTest
import NetworkingKit

class NetworkingKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //// XCTAssertEqual(NetworkingKit().text, "Hello, World!")
    }
}

#if os(Linux)
extension NetworkingKitTests {
    static var allTests : [(String, (NetworkingKitTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
#endif
