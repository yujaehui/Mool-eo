//
//  MyPostSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/27/24.
//

import Foundation
import RxDataSources

enum MyPostSectionItem {
    case post(PostModel)
    case noPost
}

struct MyPostSectionModel {
    var items: [MyPostSectionItem]
}

extension MyPostSectionModel: SectionModelType {
    typealias Item = MyPostSectionItem
    
    init(original: MyPostSectionModel, items: [MyPostSectionItem]) {
        self = original
        self.items = items
    }
}
