//
//  UIButton.Configuration+Extension.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/12/24.
//

import UIKit

extension UIButton.Configuration {
    static func check(_ title: String) -> Self {
        var config = UIButton.Configuration.filled()
        
        var titleAttr = AttributedString.init(title)
        titleAttr.font = FontStyle.contentBold
        config.attributedTitle = titleAttr
        config.titleAlignment = .center
        
        config.baseForegroundColor = ColorStyle.mainBackground
        config.baseBackgroundColor = ColorStyle.point
        config.cornerStyle = .fixed
        return config
    }
    
    static func check2(_ title: String) -> Self {
        var config = UIButton.Configuration.filled()
        
        var titleAttr = AttributedString.init(title)
        titleAttr.font = FontStyle.contentBold
        config.attributedTitle = titleAttr
        config.titleAlignment = .center
        
        config.baseForegroundColor = ColorStyle.point
        config.baseBackgroundColor = ColorStyle.subBackground
        config.cornerStyle = .fixed
        return config
    }
    
    static func capsule(_ title: String) -> Self {
        var config = UIButton.Configuration.filled()
        
        var titleAttr = AttributedString.init(title)
        titleAttr.font = FontStyle.titleBold
        config.attributedTitle = titleAttr
        config.titleAlignment = .center
        
        config.baseForegroundColor = ColorStyle.mainBackground
        config.baseBackgroundColor = ColorStyle.point
        config.cornerStyle = .capsule
        return config
    }
    
    static func capsule2(_ title: String) -> Self {
        var config = UIButton.Configuration.filled()
        
        var titleAttr = AttributedString.init(title)
        titleAttr.font = FontStyle.titleBold
        config.attributedTitle = titleAttr
        config.titleAlignment = .center
        
        config.baseForegroundColor = ColorStyle.point
        config.baseBackgroundColor = ColorStyle.subBackground
        config.cornerStyle = .capsule
        return config
    }
    
    static func text(_ title: String) -> Self {
        var config = UIButton.Configuration.borderless()
        
        var titleAttr = AttributedString.init(title)
        titleAttr.font = FontStyle.content
        config.attributedTitle = titleAttr
        config.titleAlignment = .center
        
        config.baseForegroundColor = ColorStyle.point
        return config
    }
    
    static func heart(_ imageName: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        config.image = UIImage(systemName: imageName, withConfiguration: imageConfig)
        config.imagePlacement = .leading
        config.imagePadding = 0
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        config.baseForegroundColor = ColorStyle.point
        
        return config
    }
    
    static func imageAdd() -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        config.image = UIImage(systemName: "camera", withConfiguration: imageConfig)
        
        config.baseForegroundColor = ColorStyle.point
        config.baseBackgroundColor = ColorStyle.subBackground
        
        return config
    }
}
