//
//  ChatListModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import Foundation

//MARK: - ChatListModel
struct ChatListModel: Decodable {
    let data: [ChatRoomModel]
    
    enum CodingKeys: CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decodeIfPresent([ChatRoomModel].self, forKey: .data) ?? []
    }
}

// MARK: - ChatRoomModel
struct ChatRoomModel: Decodable {
    let roomID, createdAt, updatedAt: String
    let participants: [Sender]
    let lastChat: LastChatModel

    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case createdAt, updatedAt, participants, lastChat
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.roomID = try container.decodeIfPresent(String.self, forKey: .roomID) ?? ""
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt) ?? ""
        self.participants = try container.decodeIfPresent([Sender].self, forKey: .participants) ?? []
        self.lastChat = try container.decodeIfPresent(LastChatModel.self, forKey: .lastChat) ?? LastChatModel(from: decoder)
    }
}

// MARK: - LastChatModel
struct LastChatModel: Decodable {
    let chatID, roomID, content, createdAt: String
    let sender: Sender
    let files: [String]

    enum CodingKeys: String, CodingKey {
        case chatID = "chat_id"
        case roomID = "room_id"
        case content, createdAt, sender, files
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.chatID = try container.decodeIfPresent(String.self, forKey: .chatID) ?? ""
        self.roomID = try container.decodeIfPresent(String.self, forKey: .roomID) ?? ""
        self.content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        self.sender = try container.decodeIfPresent(Sender.self, forKey: .sender) ?? Sender(from: decoder)
        self.files = try container.decodeIfPresent([String].self, forKey: .files) ?? []
    }
}
