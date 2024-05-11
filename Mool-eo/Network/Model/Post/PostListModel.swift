//
//  PostListModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import Foundation

struct PostListModel: Decodable {
    let data: [PostModel]
    let nextCursor: String

    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

struct PostModel: Decodable {
    let postId: String
    let productId: String
    let title: String
    let content: String
    let content1: String
    let files: [String]
    let likes: [String]
    let scraps: [String]
    let comments: [Comment]
    let creator: Creator
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case productId = "product_id"
        case title
        case content
        case content1
        case files
        case likes
        case scraps = "likes2"
        case comments
        case creator
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postId = try container.decodeIfPresent(String.self, forKey: .postId) ?? ""
        self.productId = try container.decodeIfPresent(String.self, forKey: .productId) ?? ""
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        self.content1 = try container.decodeIfPresent(String.self, forKey: .content1) ?? ""
        self.files = try container.decodeIfPresent([String].self, forKey: .files) ?? []
        self.likes = try container.decodeIfPresent([String].self, forKey: .likes) ?? []
        self.scraps = try container.decodeIfPresent([String].self, forKey: .scraps) ?? []
        self.comments = try container.decodeIfPresent([Comment].self, forKey: .comments) ?? []
        self.creator = try container.decodeIfPresent(Creator.self, forKey: .creator) ?? Creator(from: decoder)
    }
}

struct Comment: Decodable {
    let commentId: String
    let content: String
    let creator: Creator
    
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case content
        case creator
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentId = try container.decodeIfPresent(String.self, forKey: .commentId) ?? ""
        self.content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        self.creator = try container.decodeIfPresent(Creator.self, forKey: .creator) ?? Creator(from: decoder)
    }
}

struct Creator: Decodable {
    let userId: String
    let nick: String
    let profileImage: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nick
        case profileImage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decodeIfPresent(String.self, forKey: .userId) ?? ""
        self.nick = try container.decodeIfPresent(String.self, forKey: .nick) ?? ""
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage) ?? ""
    }
}
