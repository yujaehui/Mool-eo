//
//  ProfileRouter.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/17/24.
//

import Foundation
import Alamofire

enum ProfileRouter {
    case profileCheck
}

extension ProfileRouter: TargetType {
    
    var baseURL: String {
        APIKey.baseURL.rawValue
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .profileCheck: .get
        }
    }
    
    var path: String {
        switch self {
        case .profileCheck: "users/me/profile"
        }
    }
    
    var header: [String : String] {
        switch self {
        case .profileCheck:
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
        default: return nil
        }
    }
}
