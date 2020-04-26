//
//  URLRequester.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 26.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import Combine


class URLRequester {
    // MARK: - Enums
    enum Method: String {
        case GET, POST, PATCH, DELETE
    }
    
    enum RequestError: Error, LocalizedError {
        case unknown
        case apiError(code: Int, descr: String)
        case networkError(from: URLError)
        
        var localizedDescription: String {
            switch self {
            case .networkError(let from):
                return from.localizedDescription
            case .apiError(let code, let descr):
                return "Code \(code), \(descr)"
            case .unknown:
                return "Unknown error"
            }
        }
    }
    
    // MARK: - Variables
    var host: URL
    
    // MARK: - Inits
    init(host: URL) {
        self.host = host
    }
    
    init?(hostStr: String) {
        guard let host = URL(string: hostStr) else{
            return nil
        }
        self.host = host
    }
    
    // MARK: - Configurations
    private func getFullUrl(urlPostfix: String?, queryParams: [String: Any]?) -> URL {
        // Transforming dict to array with elements like "key=value"
        let paramsAsString = queryParams?.map({ (key: String, value: Any) -> String in
            return "\(key)=\(value)"
        }) ?? []
        // Transforming prev array to string like "key1=value1&key2=value2..."
        let paramsStr = paramsAsString.joined(separator: "&")
        // Getting full url
        var urlStr = host.absoluteString + (urlPostfix ?? "")
        if !paramsStr.isEmpty {
            urlStr += "?" + paramsStr
        }
        let url = URL(string: urlStr)!
        return url
    }
    
    private func getRequest(method: Method, urlPostfix: String?, data: Data?, queryParams: [String: Any]?, headers: [String: String]?) -> URLRequest {
        // Getting full url
        let url = getFullUrl(urlPostfix: urlPostfix, queryParams: queryParams)
        // Init request
        var request = URLRequest(url: url)
        // Setting method and body
        request.httpMethod = method.rawValue
        request.httpBody = data
        // Setting headers
        for (key, val) in (headers ?? [String: String]()) {
            request.addValue(val, forHTTPHeaderField: key)
        }
        return request
    }
    
    // MARK: - Publishers handlers
    private func errorHandler(response: URLResponse) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RequestError.unknown
        }
        let code = httpResponse.statusCode
        if code == 401 {
            throw RequestError.apiError(code: code, descr: "Unauthorized")
        } else if code == 403 {
            throw RequestError.apiError(code: code, descr: "Forbidden")
        } else if code == 404 {
            throw RequestError.apiError(code: code, descr: "Not found")
        } else if 400 ..< 500 ~= code {
            throw RequestError.apiError(code: code, descr: "Client error")
        } else if 500 ..< 600 ~= code {
            throw RequestError.apiError(code: code, descr: "Server error")
        }
        return httpResponse
    }
    
    private func getDataPublisher(request: URLRequest) -> AnyPublisher<(data: Data, response: HTTPURLResponse), RequestError> {
        let publisher = URLSession.DataTaskPublisher(request: request, session: .shared)
            .tryMap { (data: Data, response: URLResponse) -> (data: Data, response: HTTPURLResponse) in
                let resp = try self.errorHandler(response: response)
                return (data: data, response: resp)
            }
            .mapError({ (err) -> RequestError in
                if let newErr = err as? RequestError {
                    return newErr
                }
                if let newErr = err as? URLError {
                    return RequestError.networkError(from: newErr)
                }
                return RequestError.unknown
            })
            .eraseToAnyPublisher()
        return publisher
    }
    
    // MARK: - Request methods
    func get(urlPostfix: String? = nil, data: Data? = nil, queryParams: [String: Any]? = nil, headers: [String: String]? = nil) -> AnyPublisher<(data: Data, response: HTTPURLResponse), RequestError> {
        // Getting fully configured request
        let request = getRequest(method: .GET, urlPostfix: urlPostfix, data: data, queryParams: queryParams, headers: headers)
        // Getting publisher with error handling
        let publisher = getDataPublisher(request: request)
        // Returning publisher
        return publisher
        
    }
    
    func post(urlPostfix: String? = nil, data: Data? = nil, queryParams: [String: Any]? = nil, headers: [String: String]? = nil) -> AnyPublisher<(data: Data, response: HTTPURLResponse), RequestError> {
        // Getting fully configured request
        let request = getRequest(method: .POST, urlPostfix: urlPostfix, data: data, queryParams: queryParams, headers: headers)
        // Getting publisher with error handling
        let publisher = getDataPublisher(request: request)
        // Returning publisher
        return publisher
        
    }
    
    func patch(urlPostfix: String? = nil, data: Data? = nil, queryParams: [String: Any]? = nil, headers: [String: String]? = nil) -> AnyPublisher<(data: Data, response: HTTPURLResponse), RequestError> {
        // Getting fully configured request
        let request = getRequest(method: .PATCH, urlPostfix: urlPostfix, data: data, queryParams: queryParams, headers: headers)
        // Getting publisher with error handling
        let publisher = getDataPublisher(request: request)
        // Returning publisher
        return publisher
        
    }
    
    func delete(urlPostfix: String? = nil, data: Data? = nil, queryParams: [String: Any]? = nil, headers: [String: String]? = nil) -> AnyPublisher<(data: Data, response: HTTPURLResponse), RequestError> {
        // Getting fully configured request
        let request = getRequest(method: .DELETE, urlPostfix: urlPostfix, data: data, queryParams: queryParams, headers: headers)
        // Getting publisher with error handling
        let publisher = getDataPublisher(request: request)
        // Returning publisher
        return publisher
        
    }

}
