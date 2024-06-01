//
//  ChatRoomSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 6/1/24.
//

import Foundation
import RxDataSources

enum ChatRoomSectionItem {
    case chat(Chat)
}

struct ChatRoomSectionModel {
    var items: [ChatRoomSectionItem]
}

extension ChatRoomSectionModel: SectionModelType {
    typealias Item = ChatRoomSectionItem
    
    init(original: ChatRoomSectionModel, items: [ChatRoomSectionItem]) {
        self = original
        self.items = items
    }
}
