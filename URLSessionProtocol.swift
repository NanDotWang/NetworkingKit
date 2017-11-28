//
//  URLSessionProtocol.swift
//  NetworkingKit-iOS
//
//  Created by Nan Wang on 2017-11-28.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

/// URLSessionProtol for mock url session data task
public protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

/// Make URLSession confirms to URLSessionProtocol
extension URLSession: URLSessionProtocol {
    
    public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return (dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}

