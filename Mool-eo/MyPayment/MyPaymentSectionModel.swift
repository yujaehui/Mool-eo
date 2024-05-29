//
//  MyPaymentSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import Foundation
import RxDataSources

enum MyPaymentSectionItem {
    case payment(Datum)
    case noPayment
}

struct MyPaymentSectionModel {
    var items: [MyPaymentSectionItem]
}

extension MyPaymentSectionModel: SectionModelType {
    typealias Item = MyPaymentSectionItem
    
    init(original: MyPaymentSectionModel, items: [MyPaymentSectionItem]) {
        self = original
        self.items = items
    }
}
