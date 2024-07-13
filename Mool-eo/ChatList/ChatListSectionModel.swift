//
//  ChatListSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/13/24.
//

import Foundation
import RxDataSources

struct ChatListSectionModel {
    var items: [ChatRoomModel]
}

extension ChatListSectionModel: SectionModelType {
    typealias Item = ChatRoomModel
    
    init(original: ChatListSectionModel, items: [ChatRoomModel]) {
        self = original
        self.items = items
    }
}
