//
//  ChatSendQuery.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/30/24.
//

import Foundation

struct ChatSendQuery: Encodable {
    let content: String?
    let files: [String]?
}
