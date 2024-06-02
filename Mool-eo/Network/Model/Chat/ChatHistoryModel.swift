//
//  ChatHistoryModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/20/24.
//

import Foundation

// MARK: - ChatHistoryModel
struct ChatHistoryModel: Decodable {
    let data: [Chat]
    
    enum CodingKeys: CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decodeIfPresent([Chat].self, forKey: .data) ?? []
    }
}

// MARK: - Datum
//struct ChatModel: Decodable {
//    let chatID, roomID, content, createdAt: String
//    let sender: SenderModel
//    let files: [String]
//
//    enum CodingKeys: String, CodingKey {
//        case chatID = "chat_id"
//        case roomID = "room_id"
//        case content, createdAt, sender, files
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.chatID = try container.decodeIfPresent(String.self, forKey: .chatID) ?? ""
//        self.roomID = try container.decodeIfPresent(String.self, forKey: .roomID) ?? ""
//        self.content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
//        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
//        self.sender = try container.decodeIfPresent(SenderModel.self, forKey: .sender) ?? SenderModel(from: decoder)
//        self.files = try container.decodeIfPresent([String].self, forKey: .files) ?? []
//    }
//}
