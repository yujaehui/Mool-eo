//
//  FollowService.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/2/24.
//

import Foundation
import RxSwift
import Moya

enum FollowService {
    case follow(userId: String)
    case unfollow(userId: String)
}

extension FollowService: Moya.TargetType {
    
    var baseURL: URL {
        return URL(string: APIKey.baseURL.rawValue)!
    }
    
    var path: String {
        switch self {
        case .follow(let userId): "follow/\(userId)"
        case .unfollow(let userId): "follow/\(userId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .follow: .post
        case .unfollow: .delete
        }
    }
    
    var task: Task {
        switch self {
        case .follow: return .requestPlain
        case .unfollow: return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .follow:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
        case .unfollow:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
        }
    }
}
