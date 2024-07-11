//
//  CommentModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/26/24.
//

import Foundation

struct CommentModel: Decodable {
    let commentId: String
    let content: String
    let createdAt: String
    let creator: CreatorModel
    
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case content
        case createdAt
        case creator
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentId = try container.decodeIfPresent(String.self, forKey: .commentId) ?? ""
        self.content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        self.creator = try container.decodeIfPresent(CreatorModel.self, forKey: .creator) ?? CreatorModel(from: decoder)
    }
}
