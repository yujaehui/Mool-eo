//
//  HTTPHeader.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/14/24.
//

import Foundation

enum HTTPHeader: String {
    case contentType = "Content-Type"
    case json = "application/json"
    case multipart = "multipart/form-data"
    case sesacKey = "SesacKey"
    case authorization = "Authorization"
    case refresh = "Refresh"
}
