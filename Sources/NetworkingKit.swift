//
//  NetworkingKit.swift
//  NanTech
//
//  Created by Nan Wang on {TODAY}.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

/// JSON Typealias
public typealias JSON = Any
public typealias JSONDictonary = [String: Any]
public typealias StringDictonary = [String: String]

/// HTTP Methods
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

/// Result Enum
public enum Result<T> {
    case success(T?)
    case failure(Error)
}

/// Netwroking Resource
public protocol APIResource {
    var url: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: JSONDictonary { get }
    var headers: StringDictonary { get }
}

/// API service class
public final class APIService<Resource: APIResource> {
    /// Load API resource and convert json response into a dictionary model `T`
    public func load<T: Unboxable>(_ resource: Resource, completion: @escaping (Result<T>) -> ()) {
        guard let url = URL(string: resource.path, relativeTo: resource.url) else { return }
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        urlRequest.allHTTPHeaderFields = resource.headers
        urlRequest.httpMethod = resource.method.rawValue
        if !resource.parameters.isEmpty {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: resource.parameters, options: [])
        }
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in

            if let error = error {
                DispatchQueue.main.async{ completion(.failure(error)) }
                return
            }

            guard let data = data, let result: T = try? unbox(data: data) else {
                if (200...299).contains((response as! HTTPURLResponse).statusCode) {
                    DispatchQueue.main.async{ completion(.success(nil)) }
                } else {
                    DispatchQueue.main.async{ completion(.failure(UnboxError.customUnboxingFailed)) }
                }
                return
            }

            DispatchQueue.main.async{ completion(.success(result)) }

            #if DEBUG
                print("\(response)\n\(try? JSONSerialization.jsonObject(with: data, options: []))")
            #endif
            }.resume()
    }
}
