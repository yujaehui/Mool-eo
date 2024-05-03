//
//  PostService.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import Foundation
import RxSwift
import Moya

enum PostService {
    case imageUpload(query: FilesQuery)
    case postUpload(query: PostQuery)
    case postCheck(productId: String)
    case postCheckSpecific(postId: String)
    case postCheckUser(userId: String)
    case postDelete(postID: String)
    case postEdit(query: PostQuery, postId: String)
}

extension PostService: Moya.TargetType {
    
    var baseURL: URL {
        return URL(string: APIKey.baseURL.rawValue)!
    }
    
    var path: String {
        switch self {
        case .imageUpload: "posts/files"
        case .postUpload: "posts"
        case .postCheck: "posts"
        case .postCheckSpecific(let postId): "posts/\(postId)"
        case .postCheckUser(let userId): "posts/users/\(userId)"
        case .postDelete(let postId): "posts/\(postId)"
        case .postEdit(_, let postId): "posts/\(postId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .imageUpload: .post
        case .postUpload: .post
        case .postCheck: .get
        case .postCheckSpecific: .get
        case .postCheckUser: .get
        case .postDelete: .delete
        case .postEdit: .put
        }
    }
    
    var task: Task {
        switch self {
        case .imageUpload(let query):
            var formData: [MultipartFormData] = []
            for (index, fileData) in query.files.enumerated() {
                let multipartData = MultipartFormData(provider: .data(fileData), name: "files", fileName: "image\(index).png", mimeType: "image/png")
                formData.append(multipartData)
            }
            return .uploadMultipart(formData)
        case .postUpload(let query): 
            return .requestJSONEncodable(query)
        case .postCheck(let productId):
            return .requestParameters(parameters: ["product_id" : productId], encoding: URLEncoding.queryString)
        case .postCheckSpecific(_):
            return .requestPlain
        case .postCheckUser(_):
            return .requestPlain
        case .postDelete(_):
            return .requestPlain
        case .postEdit(let query, _):
            return .requestJSONEncodable(query)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .imageUpload:
            [HTTPHeader.contentType.rawValue : HTTPHeader.multipart.rawValue,
             HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        case .postUpload:
            [HTTPHeader.contentType.rawValue : HTTPHeader.json.rawValue,
             HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        case .postCheck:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        case .postCheckSpecific:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        case .postCheckUser:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        case .postDelete:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        case .postEdit:
            [HTTPHeader.contentType.rawValue : HTTPHeader.json.rawValue,
             HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
