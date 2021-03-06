//
//  URLRequester.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 26.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import UIKit
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
    
    // MARK: - Some utils
    static func buildUrlWithParams(url: URL, params: [String : Any]) -> URL {
        let queryItems = params.map { URLQueryItem(name: $0, value: "\($1)") }
        var comps = URLComponents(string: url.absoluteString)!
        comps.queryItems = queryItems
        return comps.url!
    }
    
    // MARK: - Configurations
    private func getFullUrl(urlPostfix: String?, queryParams: [String: Any]?) -> URL {
        let urlWithPostfix = self.host.appendingPathComponent(urlPostfix ?? "")
        if queryParams != nil {
            let ans = Self.buildUrlWithParams(url: urlWithPostfix, params: queryParams ?? [:])
            return ans
        }
        return urlWithPostfix
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
        for (key, val) in (headers ?? Hosts.defaultHeaders) {
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
    func get(urlPostfix: String? = nil, data: Data? = nil, queryParams: [String: Any]? = nil,
             headers: [String: String]? = nil) -> AnyPublisher<(data: Data, response: HTTPURLResponse), RequestError> {
        // Getting fully configured request
        let request = getRequest(method: .GET, urlPostfix: urlPostfix, data: data, queryParams: queryParams, headers: headers)
        // Getting publisher with error handling
        let publisher = getDataPublisher(request: request)
        // Returning publisher
        return publisher
    }
    
    func post(urlPostfix: String? = nil, data: Data? = nil, queryParams: [String: Any]? = nil,
              headers: [String: String]? = nil) -> AnyPublisher<(data: Data, response: HTTPURLResponse), RequestError> {
        // Getting fully configured request
        let request = getRequest(method: .POST, urlPostfix: urlPostfix, data: data, queryParams: queryParams, headers: headers)
        // Getting publisher with error handling
        let publisher = getDataPublisher(request: request)
        // Returning publisher
        return publisher
    }
    
    func patch(urlPostfix: String? = nil, data: Data? = nil, queryParams: [String: Any]? = nil,
               headers: [String: String]? = nil) -> AnyPublisher<(data: Data, response: HTTPURLResponse), RequestError> {
        // Getting fully configured request
        let request = getRequest(method: .PATCH, urlPostfix: urlPostfix, data: data, queryParams: queryParams, headers: headers)
        // Getting publisher with error handling
        let publisher = getDataPublisher(request: request)
        // Returning publisher
        return publisher
    }
    
    func delete(urlPostfix: String? = nil, data: Data? = nil, queryParams: [String: Any]? = nil,
                headers: [String: String]? = nil) -> AnyPublisher<(data: Data, response: HTTPURLResponse), RequestError> {
        // Getting fully configured request
        let request = getRequest(method: .DELETE, urlPostfix: urlPostfix, data: data, queryParams: queryParams, headers: headers)
        // Getting publisher with error handling
        let publisher = getDataPublisher(request: request)
        // Returning publisher
        return publisher
    }

    func download(urlPostfix: String? = nil, queryParams: [String: Any]? = nil, forObject: ImageFile? = nil,
                  completionHandler: ImageGetter.Completion = nil) -> URLSessionDownloadTask {
        // Getting fully configured request
        let request = getRequest(method: .GET, urlPostfix: urlPostfix, data: nil, queryParams: queryParams,
                headers: Hosts.imageGetHeaders)
        // Instantiating download task
        let task = URLSession.shared.downloadTask(with: request) { url, response, error in
            if let err = error {
                if let newErr = err as? URLError {
                    let err = RequestError.networkError(from: newErr)
                    completionHandler?(forObject, nil, ImageFileRequester.ApiError.requestError(err: err))
                } else {
                    let err = RequestError.unknown
                    completionHandler?(forObject, nil, ImageFileRequester.ApiError.requestError(err: err))
                }
                return
            }
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode != 200 {
                let err = RequestError.apiError(code: httpResponse.statusCode, descr: "Can't download image")
                completionHandler?(forObject, nil, ImageFileRequester.ApiError.requestError(err: err))
                return
            }
            guard let url = url else {
                let err = RequestError.apiError(code: httpResponse.statusCode, descr: "Save url is nil")
                completionHandler?(forObject, nil, ImageFileRequester.ApiError.requestError(err: err))
                return
            }
            let data = try! Data(contentsOf: url)
            let image = UIImage(data: data)
            forObject?.image = image
            completionHandler?(forObject, image, nil)
        }
        // Starting task and returning it
        task.resume()
        return task
    }

    func upload(urlPostfix: String? = nil, image: UIImage, objectType: ImageFile.ObjectType, objectId: Int,
                filename: String? = nil, queryParams: [String: Any]? = nil,
                completion: ((ImageFile?, ImageFileRequester.ApiError?) -> Void)? = nil) -> URLSessionUploadTask {
        // Configuring headers
        let boundary = UUID().uuidString
        let headers: [String : String] = [
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
            "Authorization": "Bearer \(Defaults.currentToken!.access)"
        ]
        // Configuring data
        var data = Data()
        // Object type
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"object_type\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(objectType.rawValue)".data(using: .utf8)!)
        // Object id
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"object_id\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(objectId)".data(using: .utf8)!)
        // Image
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename ?? "from-iOS.jpeg")\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.jpegData(compressionQuality: 0.9)!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        // Getting fully configured request
        var request = getRequest(method: .POST, urlPostfix: urlPostfix, data: data, queryParams: queryParams,
                headers: headers)
        request.httpBody = nil
        let uploadTask = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            if let err = error as? URLError {
                let urlErr = RequestError.networkError(from: err)
                let apiErr = ImageFileRequester.ApiError.requestError(err: urlErr)
                completion?(nil, apiErr)
                return
            }
            if let _ = error {
                completion?(nil, .requestError(err: .unknown))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion?(nil, .requestError(err: .unknown))
                return
            }
            if response.statusCode != 201 {
                completion?(nil, .requestError(err: .apiError(code: response.statusCode, descr: "Wrong status code")))
                return
            }
            guard let data = data else {
                completion?(nil, .requestError(err: .apiError(code: response.statusCode, descr: "Return data is empty")))
                return
            }
            let jsonString = String(data: data, encoding: .utf8)
            guard let imageFile = ImageFile.deserialize(from: jsonString) else {
                completion?(nil, ImageFileRequester.ApiError.decodeError(type: ImageFile.self))
                return
            }
            completion?(imageFile, nil)
        }
        uploadTask.resume()
        return uploadTask
    }

}
