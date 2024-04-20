//
//  PostRouter.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import Foundation
import Alamofire

enum PostRouter {
    case imageUpload(query: FilesQuery)
    case postUpload(query: PostQuery)
    case postEdit(query: PostQuery, postId: String)
    case postDelete(postId: String)
    case postCheck(productId: String)
    case postCheckSpecific(postId: String)
    case postCheckUser(userId: String, productId: String)
}

extension PostRouter: TargetType {
    var baseURL: String {
        APIKey.baseURL.rawValue
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .imageUpload: .post
        case .postUpload: .post
        case .postEdit: .put
        case .postDelete: .delete
        case .postCheck: .get
        case .postCheckSpecific: .get
        case .postCheckUser: .get
        }
    }
    
    var path: String {
        switch self {
        case .imageUpload:
            "posts/files"
        case .postUpload:
            "posts"
        case .postEdit:
            "posts"
        case .postDelete:
            "posts"
        case .postCheck:
            "posts"
        case .postCheckSpecific:
            "posts"
        case .postCheckUser:
            "posts/users"
        }
    }
    
    var header: [String : String] {
        switch self {
        case .imageUpload:
            [HTTPHeader.contentType.rawValue : HTTPHeader.multipart.rawValue,
             HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
        case .postUpload:
            [HTTPHeader.contentType.rawValue : HTTPHeader.json.rawValue,
             HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
        case .postEdit:
            [HTTPHeader.contentType.rawValue : HTTPHeader.json.rawValue,
             HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
        case .postDelete:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
        case .postCheck:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
        case .postCheckSpecific:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
        case .postCheckUser:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
        }
    }
    
    var parameters: String? {
        switch self {
        case .postEdit(query: _, postId: let postId): postId
        case .postDelete(postId: let postId): postId
        case .postCheckSpecific(postId: let postId): postId
        case .postCheckUser(userId: let userId, productId: _): userId
        default: nil
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .postCheck(productId: let productId):
            [URLQueryItem(name: "next", value: ""),
             URLQueryItem(name: "limit", value: "10"),
             URLQueryItem(name: "product_id", value: productId)]
        case .postCheckUser(userId: _, productId: let productId):
            [URLQueryItem(name: "next", value: ""),
             URLQueryItem(name: "limit", value: "10"),
             URLQueryItem(name: "product_id", value: productId)]
        default: nil
        }
    }
    
    var body: Data? {
        switch self {
        case .imageUpload(query: let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .postUpload(query: let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .postEdit(query: let query, postId: _):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        default: return nil
        }
    }
}
