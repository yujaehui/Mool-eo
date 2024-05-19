//
//  ChatService.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import Foundation
import RxSwift
import Moya

enum ChatService {
    case chatProduce(query: ChatProduceQuery)
    case chatCheck
}

extension ChatService: Moya.TargetType {
    
    var baseURL: URL {
        return URL(string: APIKey.baseURL.rawValue)!
    }
    
    var path: String {
        switch self {
        case .chatProduce: "chats"
        case .chatCheck: "chats"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .chatProduce: .post
        case .chatCheck: .get
        }
    }
    
    var task: Task {
        switch self {
        case .chatProduce(let query): return .requestJSONEncodable(query)
        case .chatCheck: return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .chatProduce:
            [HTTPHeader.contentType.rawValue : HTTPHeader.json.rawValue,
             HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        case .chatCheck:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
