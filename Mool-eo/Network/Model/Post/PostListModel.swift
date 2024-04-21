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
    let postID: String
    let productID: String
    let title: String
    let content: String
    let files: [String]
    let likes: [String]
    let comments: [Comment]
    let creator: Creator
    
    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case productID = "product_id"
        case title
        case content
        case files
        case likes
        case comments
        case creator
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postID = try container.decodeIfPresent(String.self, forKey: .postID) ?? ""
        self.productID = try container.decodeIfPresent(String.self, forKey: .productID) ?? ""
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        self.files = try container.decodeIfPresent([String].self, forKey: .files) ?? []
        self.likes = try container.decodeIfPresent([String].self, forKey: .likes) ?? []
        self.comments = try container.decodeIfPresent([Comment].self, forKey: .comments) ?? []
        self.creator = try container.decodeIfPresent(Creator.self, forKey: .creator) ?? Creator(from: decoder)
    }
}

struct Comment: Decodable {
    let commentID: String
    let content: String
    let creator: Creator
    
    enum CodingKeys: String, CodingKey {
        case commentID = "comment_id"
        case content
        case creator
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentID = try container.decodeIfPresent(String.self, forKey: .commentID) ?? ""
        self.content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        self.creator = try container.decodeIfPresent(Creator.self, forKey: .creator) ?? Creator(from: decoder)
    }
}

struct Creator: Decodable {
    let userID: String
    let nick: String
    let profileImage: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick
        case profileImage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decodeIfPresent(String.self, forKey: .userID) ?? ""
        self.nick = try container.decodeIfPresent(String.self, forKey: .nick) ?? ""
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage) ?? ""
    }
}
