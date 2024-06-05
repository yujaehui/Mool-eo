//
//  ChatRepository.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/30/24.
//

import Foundation
import RealmSwift

final class ChatRepository {
    private let realm = try! Realm()
    
    // MARK: - Create
    func createChat(_ data: Chat) {
        do {
            try realm.write {
                realm.add(data)
            }
        } catch {
            print(error)
        }
    }
    
    // MARK: - Fetch
    func fetchByRoom(_ room_id: String) -> [Chat] {
//        print(realm.configuration.fileURL)
        let result = realm.objects(Chat.self).where { $0.room_id == room_id }
        return Array(result)
    }
    
    func fetchLatestChatByRoom(_ room_id: String) -> Chat? {
        let result = realm.objects(Chat.self).where { $0.room_id == room_id }.sorted(byKeyPath: "createdAt", ascending: false).first
        return result
    }}
