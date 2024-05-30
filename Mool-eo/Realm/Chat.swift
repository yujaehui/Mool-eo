//
//  Chat.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/30/24.
//

import Foundation
import RealmSwift

final class Chat: Object {
    @Persisted(primaryKey: true) var pk: ObjectId
    @Persisted var chat_id: String
    @Persisted var room_id: String
    @Persisted var content: String
    @Persisted var createdAt: Date
    @Persisted var sender: Sender
    @Persisted var files: List<String>
    var filesArray: [String] {
        get {
            return files.map{$0}
        } set {
            files.removeAll()
            files.append(objectsIn: newValue)
        }
    }
    
    convenience init(chat_id: String, room_id: String, content: String, createdAt: Date, sender: Sender, filesArrar: [String]) {
        self.init()
        self.chat_id = chat_id
        self.room_id = room_id
        self.content = content
        self.createdAt = createdAt
        self.sender = sender
        self.filesArray = filesArray
    }
}

final class Sender: Object {
    @Persisted(primaryKey: true) var pk: ObjectId
    @Persisted var user_id: String
    @Persisted var nick: String
    @Persisted var profileImage: String
    
    convenience init(user_id: String, nick: String, profileImage: String) {
        self.init()
        self.user_id = user_id
        self.nick = nick
        self.profileImage = profileImage
    }
}
