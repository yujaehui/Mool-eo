//
//  PaymentQuery.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/12/24.
//

import Foundation

struct PaymentQuery: Encodable {
    let imp_uid: String
    let post_id: String
    let productName: String
    let price: Int
}
