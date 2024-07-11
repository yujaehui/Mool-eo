//
//  PaymentListSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/2/24.
//

import Foundation
import RxDataSources

struct PaymentListSectionModel {
    var items: [PaymentModel]
}

extension PaymentListSectionModel: SectionModelType {
    typealias Item = PaymentModel
    
    init(original: PaymentListSectionModel, items: [PaymentModel]) {
        self = original
        self.items = items
    }
}
