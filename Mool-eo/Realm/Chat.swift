//
//  Chat.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/30/24.
//

import Foundation
import RealmSwift

final class Chat: Object, Decodable {
    @Persisted(primaryKey: true) var pk: ObjectId
    @Persisted var chat_id: String
    @Persisted var room_id: String
    @Persisted var content: String
    @Persisted var createdAt: String
    @Persisted var sender: Sender?
    @Persisted var files: List<String>
    var filesArray: [String] {
        get {
            return files.map { $0 }
        }
        set {
            files.removeAll()
            files.append(objectsIn: newValue)
        }
    }

    // Convenience initializer
    convenience init(chat_id: String, room_id: String, content: String, createdAt: String, sender: Sender, filesArray: [String]) {
        self.init()
        self.chat_id = chat_id
        self.room_id = room_id
        self.content = content
        self.createdAt = createdAt
        self.sender = sender
        self.files.append(objectsIn: filesArray)
    }
    
    enum CodingKeys: String, CodingKey {
        case chat_id
        case room_id
        case content
        case createdAt
        case sender
        case files
    }

    // Decodable initializer
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.chat_id = try container.decodeIfPresent(String.self, forKey: .chat_id) ?? ""
        self.room_id = try container.decodeIfPresent(String.self, forKey: .room_id) ?? ""
        self.content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        self.sender = try container.decodeIfPresent(Sender.self, forKey: .sender)
        let filesArray = try container.decodeIfPresent([String].self, forKey: .files) ?? []
        self.files.append(objectsIn: filesArray)
    }
}

final class Sender: EmbeddedObject, Decodable {
    @Persisted var user_id: String
    @Persisted var nick: String
    @Persisted var profileImage: String

    // Convenience initializer
    convenience init(user_id: String, nick: String, profileImage: String) {
        self.init()
        self.user_id = user_id
        self.nick = nick
        self.profileImage = profileImage
    }
    
    enum CodingKeys: String, CodingKey {
        case user_id
        case nick
        case profileImage
    }

    // Decodable initializer
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user_id = try container.decodeIfPresent(String.self, forKey: .user_id) ?? ""
        self.nick = try container.decodeIfPresent(String.self, forKey: .nick) ?? ""
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage) ?? ""
    }
}

