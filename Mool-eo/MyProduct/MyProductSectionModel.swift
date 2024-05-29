//
//  MyProductSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/27/24.
//

import Foundation
import RxDataSources

enum MyProductSectionItem {
    case product(PostModel)
    case noProduct
}

struct MyProductSectionModel {
    var items: [MyProductSectionItem]
}

extension MyProductSectionModel: SectionModelType {
    typealias Item = MyProductSectionItem
    
    init(original: MyProductSectionModel, items: [MyProductSectionItem]) {
        self = original
        self.items = items
    }
}
