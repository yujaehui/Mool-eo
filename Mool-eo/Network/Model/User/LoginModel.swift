//
//  LoginModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/14/24.
//

import Foundation

struct LoginModel: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String
}
