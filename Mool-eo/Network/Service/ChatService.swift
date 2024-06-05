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
    case chatImageUpload(query: FilesQuery, roomId: String)
    case chatSend(query: ChatSendQuery, roomId: String)
}

extension ChatService: Moya.TargetType {
    
    var baseURL: URL {
        return URL(string: APIKey.baseURL.rawValue)!
    }
    
    var path: String {
        switch self {
        case .chatProduce: "/chats"
        case .chatListCheck: "/chats"
        case .chatHistoryCheck(let roomId, _): "/chats/\(roomId)"
        case .chatImageUpload(_, let roomId): "/chats/\(roomId)/files"
        case .chatSend(_, let roomId): "/chats/\(roomId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .chatProduce: .post
        case .chatListCheck: .get
        case .chatHistoryCheck: .get
        case .chatImageUpload: .post
        case .chatSend: .post
        }
    }
    
    var task: Task {
        switch self {
        case .chatProduce(let query): return .requestJSONEncodable(query)
        case .chatListCheck: return .requestPlain
        case .chatHistoryCheck(_, let cursorDate):
            let param = ["cursor_date" : cursorDate]
            return .requestParameters(parameters: param, encoding: URLEncoding.queryString)
        case .chatImageUpload(let query, _):
            var formData: [MultipartFormData] = []
            for (index, fileData) in query.files.enumerated() {
                let multipartData = MultipartFormData(provider: .data(fileData), name: "files", fileName: "image\(index).png", mimeType: "image/png")
                formData.append(multipartData)
            }
            return .uploadMultipart(formData)
            
        case .chatSend(let query, _): return .requestJSONEncodable(query)
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
        case .chatImageUpload:
            [HTTPHeader.contentType.rawValue : HTTPHeader.multipart.rawValue,
             HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        case .chatSend:
            [HTTPHeader.contentType.rawValue : HTTPHeader.json.rawValue,
             HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
             HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
