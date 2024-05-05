//
//  PostListSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/5/24.
//

import Foundation
import RxDataSources

struct PostListSectionModel {
    var items: [PostModel]
}

extension PostListSectionModel: SectionModelType {
    typealias Item = PostModel
    
    init(original: PostListSectionModel, items: [PostModel]) {
        self = original
        self.items = items
    }
}
