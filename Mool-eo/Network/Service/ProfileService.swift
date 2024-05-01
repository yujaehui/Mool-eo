//
//  ProfileService.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import Foundation
import RxSwift
import Moya

enum ProfileService {
    case profileCheck
    case profileEdit(query: ProfileEditQuery)
}

extension ProfileService: Moya.TargetType {
    
    var baseURL: URL {
        return URL(string: APIKey.baseURL.rawValue)!
    }
    
    var path: String {
        switch self {
        case .profileCheck: "users/me/profile"
        case .profileEdit: "users/me/profile"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .profileCheck: .get
        case .profileEdit: .put
        }
    }
    
    var task: Task {
        switch self {
        case .profileCheck: return .requestPlain
        case .profileEdit(let query):
            var formData: [MultipartFormData] = []
            formData.append(MultipartFormData(provider: .data("\(query.nick)".data(using: .utf8)!), name: "nick"))
            formData.append(MultipartFormData(provider: .data("\(query.birthDay)".data(using: .utf8)!), name: "birthDay"))
            formData.append(MultipartFormData(provider: .data(query.profile), name: "profile", fileName: "image.png", mimeType: "image/png"))
            return .uploadMultipart(formData)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .profileCheck:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
        case .profileEdit:
            [HTTPHeader.contentType.rawValue : HTTPHeader.multipart.rawValue,
             HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
        }
    }
}
