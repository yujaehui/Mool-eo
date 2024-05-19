//
//  ShoppingSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import Foundation
import RxDataSources

enum ShoppingSectionItem {
    case payment(Datum)
    case noPayment
}

struct ShoppingSectionModel {
    let title: String?
    var items: [ShoppingSectionItem]
}

extension ShoppingSectionModel: SectionModelType {
    typealias Item = ShoppingSectionItem
    
    init(original: ShoppingSectionModel, items: [ShoppingSectionItem]) {
        self = original
        self.items = items
    }
}
