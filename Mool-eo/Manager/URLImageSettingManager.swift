//
//  URLImageSettingManager.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/29/24.
//

import UIKit
import Kingfisher

class URLImageSettingManager {
    static let shared = URLImageSettingManager()
    private init() {}
    
    func setImageWithUrl(_ imageView: UIImageView, urlString: String) {
        guard let url = URL(string: APIKey.baseURL.rawValue + urlString) else { return }
        
        let modifier = AnyModifier { request in
            var urlRequest = request
            urlRequest.headers = [
                HTTPHeader.sesacKey.rawValue: APIKey.secretKey.rawValue,
                HTTPHeader.authorization.rawValue: UserDefaultsManager.accessToken!
            ]
            return urlRequest
        }
        
        imageView.kf.setImage(with: url, options: [.requestModifier(modifier)])
    }
}
