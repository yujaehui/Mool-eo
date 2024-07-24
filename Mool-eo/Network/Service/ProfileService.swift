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
    case otherUserProfileCheck(userId: String)
}

extension ProfileService: Moya.TargetType {
    
    var baseURL: URL {
        return URL(string: APIKey.baseURL.rawValue)!
    }
    
    var path: String {
        switch self {
        case .profileCheck: "/users/me/profile"
        case .profileEdit: "/users/me/profile"
        case .otherUserProfileCheck(let userId): "/users/\(userId)/profile"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .profileCheck: .get
        case .profileEdit: .put
        case .otherUserProfileCheck: .get
        }
    }
    
    var task: Task {
        switch self {
        case .profileCheck: 
            return .requestPlain
        case .profileEdit(let query):
            var formData: [MultipartFormData] = []
            formData.append(MultipartFormData(provider: .data("\(query.nick)".data(using: .utf8)!), name: "nick"))
            formData.append(MultipartFormData(provider: .data(query.profile), name: "profile", fileName: "image.jpeg", mimeType: "image/jpeg"))
            return .uploadMultipart(formData)
        case .otherUserProfileCheck:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .profileCheck, .otherUserProfileCheck:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        case .profileEdit:
            [HTTPHeader.contentType.rawValue : HTTPHeader.multipart.rawValue,
             HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
