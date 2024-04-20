//
//  PostModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import Foundation

struct PostModel: Decodable {
    let title: String
    let content: String
    let files: [String]
    
    enum CodingKeys: CodingKey {
        case title
        case content
        case files
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? "제목 없음"
        self.content = try container.decodeIfPresent(String.self, forKey: .content) ?? "내용 없음"
        self.files = try container.decodeIfPresent([String].self, forKey: .files) ?? []
    }
}
