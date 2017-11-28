//
//  MockURLSession.swift
//  NetworkingKit-iOS
//
//  Created by Nan Wang on 2017-11-28.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation
import NetworkingKit

final class MockURLSession: URLSessionProtocol {
    
    private (set) var lastURL: URL?
    private let dataTask: MockURLSessionDataTask
    
    init(dataTask: MockURLSessionDataTask = MockURLSessionDataTask()) {
        self.dataTask = dataTask
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        lastURL = request.url
        return dataTask
    }
}
