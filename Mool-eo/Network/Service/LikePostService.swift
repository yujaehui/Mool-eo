//
//  LikePostService.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import Foundation
import RxSwift
import Moya

enum LikePostService {
    case likePostUpload(query: LikePostQuery, postId: String)
    case likePostCheck(limit: String, next: String)
}

extension LikePostService: Moya.TargetType {
    
    var baseURL: URL {
        return URL(string: APIKey.baseURL.rawValue)!
    }
    
    var path: String {
        switch self {
        case .likePostUpload(query: _, postId: let postId): "/posts/\(postId)/like"
        case .likePostCheck: "/posts/likes/me"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .likePostUpload(query: _, postId: _): .post
        case .likePostCheck : .get
        }
    }
    
    var task: Task {
        switch self {
        case .likePostUpload(let query, _): return .requestJSONEncodable(query)
        case .likePostCheck(let limit, let next):
            let param = ["limit" : limit,
                         "next" : next]
            return .requestParameters(parameters: param, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .likePostUpload(query: _, postId: _):
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        case .likePostCheck:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}

