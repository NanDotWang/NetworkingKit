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
    
    var dummyAPIResource: APIResource<DummyModel>!

    override func setUp() {
        super.setUp()
        let url = URL(string: "https://api.myjson.com/bins/69rr7")!
        dummyAPIResource = APIResource(url: url, parse: DummyModel.init)
    }
    
    override func tearDown() {
        super.tearDown()
        dummyAPIResource = nil
    }
    
    func testResumeCalled() {
        let mockTask = MockURLSessionDataTask()
        let mockSession = MockURLSession(dataTask: mockTask)
        let service = APIService(urlSession: mockSession)
        service.load(resource: dummyAPIResource)
        XCTAssertTrue(mockTask.resumeWasCalled)
    }
    
    func testLoadingResource() {
        let mockSession = MockURLSession()
        let service = APIService(urlSession: mockSession)
        service.load(resource: dummyAPIResource)
        XCTAssert(mockSession.lastURL == dummyAPIResource.url)
    }
    
    func testLoadingData() {
        let expectedData = "Hello Data".data(using: .utf8)
        let mockSession = MockURLSession()
        mockSession.mockData = expectedData
        let service = APIService(urlSession: mockSession)
        var resultData: Data?
        service.load(resource: dummyAPIResource) { result in
            switch result {
            case .success(let dummyModel):
                resultData = dummyModel.data
            case .failure(_):
                resultData = nil
            }
            XCTAssertEqual(resultData, expectedData)
        }
    }
    
    func testLoadingError() {
        let expectedError = NetworkingError.noInternet
        let mockSession = MockURLSession()
        mockSession.mockError = NSError(domain: "com.test.networkingKit", code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        let service = APIService(urlSession: mockSession)
        var resultError: NetworkingError?
        service.load(resource: dummyAPIResource) { (result) in
            switch result {
            case .success(_):
                resultError = nil
            case .failure(let error):
                resultError = error
            }
            guard let resultError = resultError else {
                XCTFail("Expected failure error at this point.")
                return
            }
            XCTAssertEqual(resultError, expectedError)
        }
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
