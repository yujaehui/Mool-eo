//
//  ChatHistoryModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/20/24.
//

import Foundation

// MARK: - ChatHistoryModel
struct ChatHistoryModel: Decodable {
    let data: [Chat]
    
    enum CodingKeys: CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decodeIfPresent([Chat].self, forKey: .data) ?? []
    }
}
