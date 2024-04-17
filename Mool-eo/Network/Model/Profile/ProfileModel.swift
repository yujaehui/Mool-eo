//
//  ProfileModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/17/24.
//

import Foundation

struct ProfileModel: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let birthDay: String
    let profileImage: String
    let followers: [Follow]
    let following: [Follow]
    let posts: [String]
    
    enum CodingKeys: CodingKey {
        case user_id
        case email
        case nick
        case birthDay
        case profileImage
        case followers
        case following
        case posts
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user_id = try container.decode(String.self, forKey: .user_id)
        self.email = try container.decode(String.self, forKey: .email)
        self.nick = try container.decode(String.self, forKey: .nick)
        self.birthDay = try container.decodeIfPresent(String.self, forKey: .birthDay) ?? ""
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage) ?? ""
        self.followers = try container.decodeIfPresent([Follow].self, forKey: .followers) ?? []
        self.following = try container.decodeIfPresent([Follow].self, forKey: .following) ?? []
        self.posts = try container.decodeIfPresent([String].self, forKey: .posts) ?? []
    }
}

struct Follow: Decodable {
    let user_id: String
    let email: String
    let profileImage: String
    
    enum CodingKeys: CodingKey {
        case user_id
        case email
        case profileImage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user_id = try container.decode(String.self, forKey: .user_id)
        self.email = try container.decode(String.self, forKey: .email)
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage) ?? ""
    }
}
