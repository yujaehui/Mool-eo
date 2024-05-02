//
//  FollowModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/2/24.
//

import Foundation

struct FollowModel: Decodable {
    let nick: String
    let opponent_nick: String
    let following_status: Bool
}
