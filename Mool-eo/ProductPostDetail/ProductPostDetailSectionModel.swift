//
//  ProductPostDetailSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/11/24.
//

import Foundation
import RxDataSources

enum ProductPostDetailSectionItem {
    case image(PostModel)
    case info(PostModel)
    case detail(PostModel)
}

struct ProductPostDetailSectionModel {
    let title: String?
    var items: [ProductPostDetailSectionItem]
}

extension ProductPostDetailSectionModel: SectionModelType {
    typealias Item = ProductPostDetailSectionItem
    
    init(original: ProductPostDetailSectionModel, items: [ProductPostDetailSectionItem]) {
        self = original
        self.items = items
    }
}
