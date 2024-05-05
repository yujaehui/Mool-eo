//
//  ScrapPostSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/5/24.
//

import Foundation
import RxDataSources

struct ScrapPostListSectionModel {
    var items: [PostModel]
}

extension ScrapPostListSectionModel: SectionModelType {
    typealias Item = PostModel
    
    init(original: ScrapPostListSectionModel, items: [PostModel]) {
        self = original
        self.items = items
    }
}
