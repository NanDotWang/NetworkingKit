//
//  URLSessionDataTaskProtocol.swift
//  NetworkingKit-iOS
//
//  Created by Nan Wang on 2017-11-28.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

public protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }
