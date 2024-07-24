//
//  URLImageSettingManager.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/29/24.
//

import UIKit
import Kingfisher

enum ImageViewSize {
    case small // 1 to 50
    case medium // 51 to 100
    case large // 101 to 150
    case extraLarge // 151 to 200
    case screenWidth // UIScreen.main.bounds.width for both width and height
    
    func getSize() -> CGSize {
        switch self {
        case .small:
            return CGSize(width: 50, height: 50)
        case .medium:
            return CGSize(width: 100, height: 100)
        case .large:
            return CGSize(width: 150, height: 150)
        case .extraLarge:
            return CGSize(width: 200, height: 200)
        case .screenWidth:
            let width = UIScreen.main.bounds.width
            return CGSize(width: width, height: width)
        }
    }
}

final class URLImageSettingManager {
    static let shared = URLImageSettingManager()
    private init() {}
    
    func setImageWithUrl(_ imageView: UIImageView, urlString: String, imageViewSize: ImageViewSize = .screenWidth) {
        guard let url = URL(string: APIKey.baseURL.rawValue + "/" + urlString) else {
            print("Invalid URL")
            return
        }
        print("URL: \(url)")
        
        let modifier = AnyModifier { request in
            var urlRequest = request
            urlRequest.headers = [
                HTTPHeader.sesacKey.rawValue: APIKey.secretKey.rawValue,
                HTTPHeader.authorization.rawValue: UserDefaultsManager.accessToken!
            ]
            return urlRequest
        }
        
        let processor = DownsamplingImageProcessor(size: imageViewSize.getSize())
        
        imageView.kf.indicatorType = .activity
        
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .requestModifier(modifier),
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.25)),
                .cacheOriginalImage
            ]
        )
    }
}
