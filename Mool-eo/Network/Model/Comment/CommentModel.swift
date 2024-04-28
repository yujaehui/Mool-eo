//
//  CommentModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/26/24.
//

import Foundation

struct CommentModel: Decodable {
    let commentID, content, createdAt: String
    let creator: Creator
    
    enum CodingKeys: String, CodingKey {
        case commentID = "comment_id"
        case content, createdAt, creator
    }
}
