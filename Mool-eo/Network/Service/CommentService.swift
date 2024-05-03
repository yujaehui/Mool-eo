//
//  CommentService.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import Foundation
import RxSwift
import Moya

enum CommentService {
    case uploadComment(query: CommentQuery, postId: String)
    case commentDelete(postId: String, commentId: String)
}

extension CommentService: Moya.TargetType {
    
    var baseURL: URL {
        return URL(string: APIKey.baseURL.rawValue)!
    }
    
    var path: String {
        switch self {
        case .uploadComment(_, let postId): "/posts/\(postId)/comments"
        case .commentDelete(let postId, let commentId): "posts/\(postId)/comments/\(commentId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .uploadComment: .post
        case .commentDelete: .delete
        }
    }
    
    var task: Task {
        switch self {
        case .uploadComment(let query, _):
            return .requestJSONEncodable(query)
        case .commentDelete:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .uploadComment:
            [HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
             HTTPHeader.sesacKey.rawValue: APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue: UserDefaultsManager.accessToken!]
        case .commentDelete:
            [HTTPHeader.sesacKey.rawValue: APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue: UserDefaultsManager.accessToken!]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
