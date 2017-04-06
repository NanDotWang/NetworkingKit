//
//  NetworkingKit.swift
//  NanTech
//
//  Created by Nan Wang on {TODAY}.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

// MARK: - JSON Typealias

public typealias JSON = Any
public typealias JSONDictonary = [String: Any]
public typealias StringDictonary = [String: String]

// MARK: - HTTP Methods

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Result Enum

public enum Result<T> {
    case success(T?)
    case failure(Error)
}

// MARK: - Netwroking Resource

public protocol APIResource {
    var url: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: JSONDictonary { get }
    var headers: StringDictonary { get }
}

// MARK: - API service class

public final class APIService<Resource: APIResource> {

    /// Load API resource and convert json response into a dictionary model `T`
    public func load<T>(resource: Resource, parser: @escaping (JSON) -> T?, completion: @escaping (Result<T>) -> Void) {
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

            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let result: T = parser(json) else {
                if (200...299).contains((response as! HTTPURLResponse).statusCode) {
                    DispatchQueue.main.async{ completion(.success(nil)) }
                } else {
                    DispatchQueue.main.async{ completion(.failure(NetworkingError.parsingFailed)) }
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

// MARK: - Error type

/// Error type that Networking throws in case an unrecoverable error was encountered
public enum NetworkingError: Error {
    /// Parsing data failed
    case parsingFailed
}

/// Extension making `NetworkingError` conform to `CustomStringConvertible`
extension NetworkingError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .parsingFailed:
            return "[Networking] Parsing failed"
        }
    }
}
