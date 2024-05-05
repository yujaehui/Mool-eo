//
//  PostDetailSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/5/24.
//

import Foundation
import RxDataSources

enum PostDetailSectionItem {
    case post(PostModel)
    case comment(Comment)
}

struct PostDetailSectionModel {
    var items: [PostDetailSectionItem]
}

extension PostDetailSectionModel: SectionModelType {
    typealias Item = PostDetailSectionItem
    
    init(original: PostDetailSectionModel, items: [PostDetailSectionItem]) {
        self = original
        self.items = items
    }
}
