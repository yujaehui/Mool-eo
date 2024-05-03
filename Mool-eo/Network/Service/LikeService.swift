//
//  LikeService.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import Foundation
import RxSwift
import Moya

enum LikeService {
    case likeUpload(query: LikeQuery, postId: String)
}

extension LikeService: Moya.TargetType {
    
    var baseURL: URL {
        return URL(string: APIKey.baseURL.rawValue)!
    }
    
    var path: String {
        switch self {
        case .likeUpload(query: _, postId: let postId): "posts/\(postId)/like"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .likeUpload(query: _, postId: _): .post
        }
    }
    
    var task: Task {
        switch self {
        case .likeUpload(let query, _): return .requestJSONEncodable(query)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .likeUpload(query: _, postId: _):
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}

