//
//  NetworkingKitTests.swift
//  NanTech
//
//  Created by Nan Wang on 2017-04-07.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation
import XCTest
import NetworkingKit

class NetworkingKitTests: XCTestCase {
    
    var apiService: APIService!
    let mockURLSessionDataTask = MockURLSessionDataTask()
    lazy var mockURLSession = MockURLSession(dataTask: mockURLSessionDataTask)
    
    override func setUp() {
        super.setUp()
        apiService = APIService(urlSession: mockURLSession)
    }
    
    func testAPIServiceLoadCorrectResource() {
        let url = URL(string: "www.apple.com")!
        let apiResource = APIResource(url: url, parse: DummyModel.init)
        apiService.load(resource: apiResource)
        XCTAssert(mockURLSession.lastURL == url)
        XCTAssertTrue(mockURLSessionDataTask.resumeWasCalled)
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
