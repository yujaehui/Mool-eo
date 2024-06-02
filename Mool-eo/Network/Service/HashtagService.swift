//
//  HashtagService.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/17/24.
//

import Foundation
import RxSwift
import Moya

enum HashtagService {
    case hashtag(hashtag: String, productId: String, limit: String, next: String)
}

extension HashtagService: Moya.TargetType {
    
    var baseURL: URL {
        return URL(string: APIKey.baseURL.rawValue)!
    }
    
    var path: String {
        switch self {
        case .hashtag: "/posts/hashtags"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .hashtag: .get
        }
    }
    
    var task: Task {
        switch self {
        case .hashtag(let hashtag, let productId, let limit, let next):
            let param = ["hashTag" : hashtag,
                         "product_id" : productId,
                         "limit" : limit,
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
