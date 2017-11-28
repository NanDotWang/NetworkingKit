//
//  MockURLSessionDataTask.swift
//  NetworkingKit-iOS
//
//  Created by Nan Wang on 2017-11-28.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation
import NetworkingKit

final class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    
    private (set) var resumeWasCalled = false
    
    func resume() {
        resumeWasCalled = true
    }
}
