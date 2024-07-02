//
//  PaymentListSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/2/24.
//

import Foundation
import RxDataSources

struct PaymentListSectionModel {
    var items: [Datum]
}

extension PaymentListSectionModel: SectionModelType {
    typealias Item = Datum
    
    init(original: PaymentListSectionModel, items: [Datum]) {
        self = original
        self.items = items
    }
}
