//
//  UserService.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import Foundation
import RxSwift
import Moya

enum UserService {
    case join(query: JoinQuery)
    case email(query: EmailQuery)
    case login(query: LoginQuery)
    case refresh
    case withdraw
}

extension UserService: Moya.TargetType {
    
    var baseURL: URL {
        return URL(string: APIKey.baseURL.rawValue)!
    }
    
    var path: String {
        switch self {
        case .join: "/users/join"
        case .email: "/validation/email"
        case .login: "/users/login"
        case .refresh: "/auth/refresh"
        case .withdraw: "/users/withdraw"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .join: .post
        case .email: .post
        case .login: .post
        case .refresh: .get
        case .withdraw: .get
        }
    }
    
    var task: Task {
        switch self {
        case .join(let query): return .requestJSONEncodable(query)
        case .email(let query): return .requestJSONEncodable(query)
        case .login(let query): return .requestJSONEncodable(query)
        case .refresh: return .requestPlain
        case .withdraw: return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .join:
            [HTTPHeader.contentType.rawValue : HTTPHeader.json.rawValue,
             HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue]
        case .email:
            [HTTPHeader.contentType.rawValue : HTTPHeader.json.rawValue,
             HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue]
        case .login:
            [HTTPHeader.contentType.rawValue : HTTPHeader.json.rawValue,
             HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue]
        case .refresh:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!,
             HTTPHeader.refresh.rawValue : UserDefaultsManager.refreshToken!]
        case .withdraw:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
