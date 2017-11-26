//
//  NetworkingKit.swift
//  NanTech
//
//  Created by Nan Wang on {TODAY}.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

/// MARK: - JSON Typealias
public typealias JSON = Any
public typealias JSONDictonary = [String: Any]
public typealias StringDictonary = [String: String]

/// MARK: - HTTP Methods
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

/// MARK: - Result Enum
public enum Result<T> {
    case success(T)
    case failure(Error)
}

/// MARK: - API Resource
public struct APIResource<T> {
    let url: URL
    let method: HTTPMethod
    let body: JSONDictonary
    let headers: StringDictonary
    let parse: (Data) -> T?
}

/// Extension on HTTPURLResponse
public extension HTTPURLResponse {

    /// Check if a response is success or not
    func isSuccess() -> Bool {
        return (200...299).contains(self.statusCode)
    }
}

// MARK: - API service class
public final class APIService {

    /// Load API resource and convert json response into a dictionary model `T`
    public func load<T>(resource: APIResource<T>, completion: ((Result<T>) -> Void)? = nil) {
        var urlRequest = URLRequest(url: resource.url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        urlRequest.allHTTPHeaderFields = resource.headers
        urlRequest.httpMethod = resource.method.rawValue
        if !resource.body.isEmpty {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: resource.body, options: [])
        }
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in

            switch error {
            case .some(let error as NSError) where error.code == NSURLErrorNotConnectedToInternet:
                DispatchQueue.main.async{ completion?(.failure(NetworkingError.noInternet)) }
            case .some(let error):
                DispatchQueue.main.async{ completion?(.failure(error)) }
            case .none:
                guard let result = data.flatMap(resource.parse) else {
                    DispatchQueue.main.async{ completion?(.failure(NetworkingError.parsingFailed)) }
                    return
                }
                DispatchQueue.main.async{ completion?(.success(result)) }
            }
            }.resume()
    }

    public init() {}
}

// MARK: - Error type

/// Error type that Networking throws in case an unrecoverable error was encountered
public enum NetworkingError: Error {
    /// Not connected to internet
    case noInternet
    /// Parsing data failed
    case parsingFailed
}

/// Extension making `NetworkingError` conform to `CustomStringConvertible`
extension NetworkingError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .noInternet: return "[Networking] Not connected to internet"
        case .parsingFailed: return "[Networking] Parsing failed"
        }
    }
}
