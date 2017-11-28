//
//  NetworkingKit.swift
//  NanTech
//
//  Created by Nan Wang on 2017-04-07.
//  Copyright © 2017 NanTech. All rights reserved.
//
import Foundation

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
    let body: [String: Any]
    let headers: [String: String]
    let parse: (Data) -> T?

    public init(url: URL, method: HTTPMethod = .get, body: [String: Any] = [:], headers: [String: String] = [:], parse: @escaping (Data) -> T?) {
        self.url = url
        self.method = method
        self.body = body
        self.headers = headers
        self.parse = parse
    }
}

/// An initializer that helps converting data to json object.
public extension APIResource {
    init(url: URL, method: HTTPMethod = .get, body: [String: Any] = [:], headers: [String: String] = [:], parseJSON: @escaping (Any) -> T?) {
        self.url = url
        self.method = method
        self.body = body
        self.headers = headers
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            return json.flatMap(parseJSON)
        }
    }
}

// MARK: - API service class
public final class APIService {

    /// URLSession to make the request
    private let urlSession: URLSessionProtocol

    /// Initialise with default shared url session
    public init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }

    /// Load API resource and convert json response into a dictionary model `T`
    public func load<T>(resource: APIResource<T>, completion: ((Result<T>) -> Void)? = nil) {
        var urlRequest = URLRequest(url: resource.url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        urlRequest.httpMethod = resource.method.rawValue
        if !resource.headers.isEmpty {
            urlRequest.allHTTPHeaderFields = resource.headers
        }
        if !resource.body.isEmpty {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: resource.body, options: [])
        }
        let task = urlSession.dataTask(with: urlRequest) { data, _, error in

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
        }
        task.resume()
    }
}

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
