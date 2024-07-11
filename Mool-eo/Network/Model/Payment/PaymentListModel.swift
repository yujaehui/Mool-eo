//
//  PaymentListModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/12/24.
//

import Foundation

// MARK: - PaymentListModel
struct PaymentListModel: Decodable {
    let data: [PaymentModel]
}

// MARK: - PaymentModel
struct PaymentModel: Decodable {
    let paymentID, buyerID, postID, merchantUid: String
    let productName: String
    let price: Int
    let paidAt: String

    enum CodingKeys: String, CodingKey {
        case paymentID = "payment_id"
        case buyerID = "buyer_id"
        case postID = "post_id"
        case merchantUid = "merchant_uid"
        case productName, price, paidAt
    }
}
