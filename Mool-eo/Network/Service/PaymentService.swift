//
//  PaymentService.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/12/24.
//

import Foundation
import RxSwift
import Moya

enum PaymentService {
    case paymentValidation(query: PaymentQuery)
    case paymentCheck
}

extension PaymentService: Moya.TargetType {
    
    var baseURL: URL {
        return URL(string: APIKey.baseURL.rawValue)!
    }
    
    var path: String {
        switch self {
        case .paymentValidation: "payments/validation"
        case .paymentCheck: "payments/me"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .paymentValidation: .post
        case .paymentCheck: .get
        }
    }
    
    var task: Task {
        switch self {
        case .paymentValidation(let query): return .requestJSONEncodable(query)
        case .paymentCheck: return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
         HTTPHeader.authorization.rawValue : UserDefaultsManager.accessToken!]
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}

