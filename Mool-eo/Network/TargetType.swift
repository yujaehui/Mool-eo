//
//  TargetType.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/14/24.
//

import Foundation
import Alamofire

protocol TargetType {
    var baseURL: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var header: [String : String] { get }
    var parameters: String? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
}

extension TargetType {
    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL()
        var urlComponents = URLComponents(url: url.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        
        if let parameters = parameters {
            urlComponents?.path += parameters
        }
        
        // Add query items if available
        if let queryItems = queryItems {
            urlComponents?.queryItems = queryItems
        }
        
        guard let urlWithQuery = urlComponents?.url else {
            throw AFError.invalidURL(url: url.appendingPathComponent(path))
        }
        
        var urlRequest = try URLRequest(url: urlWithQuery, method: method)
        urlRequest.allHTTPHeaderFields = header
        urlRequest.httpBody = body

        return urlRequest
    }
}
