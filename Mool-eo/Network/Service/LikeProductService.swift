//
//  LikeProductService.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import Foundation
import RxSwift
import Moya

enum LikeProductService {
    case likeProductUpload(query: LikeProductQuery, postId: String)
    case likeProdcutCheck(limit: String, next: String)
}

extension LikeProductService: Moya.TargetType {
    
    var baseURL: URL {
        return URL(string: APIKey.baseURL.rawValue)!
    }
    
    var path: String {
        switch self {
        case .likeProductUpload(query: _, postId: let postId): "/posts/\(postId)/like-2"
        case .likeProdcutCheck: "/posts/likes-2/me"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .likeProductUpload: .post
        case .likeProdcutCheck: .get
        }
    }
    
    var task: Task {
        switch self {
        case .likeProductUpload(let query, _): 
            return .requestJSONEncodable(query)
        case .likeProdcutCheck(let limit, let next):
            let param = ["limit" : limit,
                         "next" : next]
            return .requestParameters(parameters: param, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
         HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
