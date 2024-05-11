//
//  PostQuery.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import Foundation

struct PostQuery: Encodable {
    let title: String
    let content: String
    let content1: String?
    let product_id: String
    let files: [String]?
}
