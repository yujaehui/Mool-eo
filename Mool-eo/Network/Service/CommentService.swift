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
}

extension CommentService: Moya.TargetType {
    
    var baseURL: URL {
        return URL(string: APIKey.baseURL.rawValue)!
    }
    
    var path: String {
        switch self {
        case .uploadComment(_, let postId):
            return "/posts/\(postId)/comments"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .uploadComment:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .uploadComment(let query, _):
            return .requestJSONEncodable(query)
        }
    }
    
    var headers: [String : String]? {
        return [HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                HTTPHeader.sesacKey.rawValue: APIKey.secretKey.rawValue,
                HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? ""]
    }
}
