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
    case chatListCheck
    case chatHistoryCheck(roomId: String, cursorDate: String)
}

extension ChatService: Moya.TargetType {
    
    var baseURL: URL {
        return URL(string: APIKey.baseURL.rawValue)!
    }
    
    var path: String {
        switch self {
        case .chatProduce: "chats"
        case .chatListCheck: "chats"
        case .chatHistoryCheck(let roomId, _): "chats/\(roomId)"
        
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .chatProduce: .post
        case .chatListCheck: .get
        case .chatHistoryCheck: .get
        }
    }
    
    var task: Task {
        switch self {
        case .chatProduce(let query): return .requestJSONEncodable(query)
        case .chatListCheck: return .requestPlain
        case .chatHistoryCheck(_, let cursorDate):
            let param = ["cursor_date" : cursorDate]
            return .requestParameters(parameters: param, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .chatProduce:
            [HTTPHeader.contentType.rawValue : HTTPHeader.json.rawValue,
             HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        case .chatListCheck:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        case .chatHistoryCheck:
            [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
