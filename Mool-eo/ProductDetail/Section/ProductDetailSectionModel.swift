//
//  ProductDetailSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/11/24.
//

import Foundation
import RxDataSources

enum ProductDetailSectionItem {
    case image(PostModel)
    case info(PostModel)
    case detail(PostModel)
}

struct ProductDetailSectionModel {
    let title: String?
    var items: [ProductDetailSectionItem]
}

extension ProductDetailSectionModel: SectionModelType {
    typealias Item = ProductDetailSectionItem
    
    init(original: ProductDetailSectionModel, items: [ProductDetailSectionItem]) {
        self = original
        self.items = items
    }
}
