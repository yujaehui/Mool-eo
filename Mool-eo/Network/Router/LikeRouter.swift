//
//  LikeRouter.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/28/24.
//

import Foundation
import Alamofire

enum LikeRouter {
    case likeUpload(query: LikeQuery, postId: String)
}

extension LikeRouter: TargetType {
    
    var baseURL: String {
        APIKey.baseURL.rawValue
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .likeUpload(query: _, postId: _): .post
        }
    }
    
    var path: String {
        switch self {
        case .likeUpload(query: _, postId: let postId): "posts/\(postId)/like"
        }
    }
    
    var header: [String : String] {
        switch self {
        case .likeUpload(query: _, postId: _):
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
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
        case .likeUpload(query: let query, postId: _):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .useDefaultKeys
            return try? encoder.encode(query)
        }
    }
}
