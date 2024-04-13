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
    
    static func text(_ title: String) -> Self {
        var config = UIButton.Configuration.borderless()
        
        var titleAttr = AttributedString.init(title)
        titleAttr.font = FontStyle.content
        config.attributedTitle = titleAttr
        config.titleAlignment = .center
        
        config.baseForegroundColor = ColorStyle.point
        return config
    }
}
