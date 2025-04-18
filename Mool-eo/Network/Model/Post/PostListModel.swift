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
    let likePost: [String]
    let likesProduct: [String]
    let comments: [CommentModel]
    let creator: CreatorModel
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case productId = "product_id"
        case title
        case content
        case content1
        case files
        case likePost = "likes"
        case likesProduct = "likes2"
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
        self.likePost = try container.decodeIfPresent([String].self, forKey: .likePost) ?? []
        self.likesProduct = try container.decodeIfPresent([String].self, forKey: .likesProduct) ?? []
        self.comments = try container.decodeIfPresent([CommentModel].self, forKey: .comments) ?? []
        self.creator = try container.decodeIfPresent(CreatorModel.self, forKey: .creator) ?? CreatorModel(from: decoder)
    }
}

struct CreatorModel: Decodable {
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
