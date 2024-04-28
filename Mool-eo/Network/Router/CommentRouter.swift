//
//  CommentRouter.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/27/24.
//

import Foundation
import Alamofire

enum CommentRouter {
    case commentUpload(query: CommentQuery, postId: String)
}

extension CommentRouter: TargetType {
    
    var baseURL: String {
        APIKey.baseURL.rawValue
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .commentUpload(query: _, postId: _): .post
        }
    }
    
    var path: String {
        switch self {
        case .commentUpload(query: _, postId: let postId): "posts/\(postId)/comments"
        }
    }
    
    var header: [String : String] {
        switch self {
        case .commentUpload(query: _, postId: _):
            [HTTPHeader.contentType.rawValue : HTTPHeader.json.rawValue,
             HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
        }
    }
    
    var parameters: String? {
        nil
    }
    
    var queryItems: [URLQueryItem]? {
        nil
    }
    
    var body: Data? {
        switch self {
        case .commentUpload(query: let query, postId: _):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .useDefaultKeys
            return try? encoder.encode(query)
        }
    }
}
