//
//  LikeListSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/5/24.
//

import Foundation
import RxDataSources

struct LikeListSectionModel {
    var items: [PostModel]
}

extension LikeListSectionModel: SectionModelType {
    typealias Item = PostModel
    
    init(original: LikeListSectionModel, items: [PostModel]) {
        self = original
        self.items = items
    }
}
