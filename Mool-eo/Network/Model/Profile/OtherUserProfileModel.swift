//
//  OtherUserProfileModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/2/24.
//

import Foundation

struct OtherUserProfileModel: Decodable {
    let user_id: String
    let nick: String
    let profileImage: String
    let followers: [Follow]
    let following: [Follow]
    let posts: [String]
    
    enum CodingKeys: String, CodingKey {
        case user_id
        case nick
        case profileImage
        case followers
        case following
        case posts
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user_id = try container.decode(String.self, forKey: .user_id)
        self.nick = try container.decode(String.self, forKey: .nick)
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage) ?? ""
        self.followers = try container.decodeIfPresent([Follow].self, forKey: .followers) ?? []
        self.following = try container.decodeIfPresent([Follow].self, forKey: .following) ?? []
        self.posts = try container.decodeIfPresent([String].self, forKey: .posts) ?? []
    }
}
