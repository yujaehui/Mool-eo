//
//  ChatListModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import Foundation

//MARK: - ChatListModel
struct ChatListModel: Decodable {
    let data: [ChatModel]
    
    enum CodingKeys: CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decodeIfPresent([ChatModel].self, forKey: .data) ?? []
    }
}

// MARK: - ChatModel
struct ChatModel: Decodable {
    let roomID, createdAt, updatedAt: String
    let participants: [Sender]
    let lastChat: LastChat

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
        self.lastChat = try container.decodeIfPresent(LastChat.self, forKey: .lastChat) ?? LastChat(from: decoder)
    }
}

// MARK: - LastChat
struct LastChat: Decodable {
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

// MARK: - Sender
struct Sender: Decodable {
    let userID, nick: String
    let profileImage: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, profileImage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decodeIfPresent(String.self, forKey: .userID) ?? ""
        self.nick = try container.decodeIfPresent(String.self, forKey: .nick) ?? ""
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage) ?? ""
    }
}
