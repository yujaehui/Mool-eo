//
//  ScrapService.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import Foundation
import RxSwift
import Moya

enum ScrapService {
    case scrapUpload(query: ScrapQuery, postId: String)
    case scrapPostCheck(limit: String, next: String)
}

extension ScrapService: Moya.TargetType {
    
    var baseURL: URL {
        return URL(string: APIKey.baseURL.rawValue)!
    }
    
    var path: String {
        switch self {
        case .scrapUpload(query: _, postId: let postId): "posts/\(postId)/like-2"
        case .scrapPostCheck: "posts/likes-2/me"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .scrapUpload(query: _, postId: _): .post
        case .scrapPostCheck : .get
        }
    }
    
    var task: Task {
        switch self {
        case .scrapUpload(let query, _): return .requestJSONEncodable(query)
        case .scrapPostCheck(let limit, let next):
            let param = ["limit" : limit,
                         "next" : next]
            return .requestParameters(parameters: param, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .scrapUpload(query: _, postId: _):
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        case .scrapPostCheck:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
