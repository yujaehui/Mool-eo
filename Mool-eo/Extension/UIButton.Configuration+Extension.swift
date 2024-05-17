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
    
    static func capsule(_ title: String) -> Self {
        var config = UIButton.Configuration.filled()
        
        var titleAttr = AttributedString.init(title)
        titleAttr.font = FontStyle.description
        config.attributedTitle = titleAttr
        config.titleAlignment = .center
        
        config.baseForegroundColor = ColorStyle.point
        config.baseBackgroundColor = ColorStyle.subBackground
        config.cornerStyle = .capsule
        return config
    }
    
    static func capsuleFill(_ title: String) -> Self {
        var config = UIButton.Configuration.filled()
        
        var titleAttr = AttributedString.init(title)
        titleAttr.font = FontStyle.description
        config.attributedTitle = titleAttr
        config.titleAlignment = .center
        
        config.baseForegroundColor = ColorStyle.mainBackground
        config.baseBackgroundColor = ColorStyle.point
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
        config.imagePadding = 0
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        config.baseForegroundColor = ColorStyle.point
        
        return config
    }
    
    static func chevron() -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 16)
        config.image = UIImage(systemName: "chevron.right", withConfiguration: imageConfig)
        config.imagePadding = 0
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        config.baseForegroundColor = ColorStyle.point
        
        return config
    }
    
    static func postAdd(_ title: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        
        var titleAttr = AttributedString.init(title)
        titleAttr.font = FontStyle.titleBold
        config.attributedTitle = titleAttr
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 16)
        config.image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        config.imagePadding = 5
        
        config.baseForegroundColor = .white
        config.baseBackgroundColor = ColorStyle.point
        config.cornerStyle = .capsule
        config.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 15)
        
        return config
    }
    
    static func imageAdd() -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 18)
        config.image = UIImage(systemName: "camera", withConfiguration: imageConfig)
        
        config.baseForegroundColor = ColorStyle.point
        config.baseBackgroundColor = ColorStyle.subBackground
        
        return config
    }
    
    static func seeMore() -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        
        var titleAttr = AttributedString.init("더보기")
        titleAttr.font = FontStyle.content
        config.attributedTitle = titleAttr
        config.titleAlignment = .trailing
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 14)
        config.image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        config.imagePlacement = .leading
        config.imagePadding = 5
        
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        config.baseForegroundColor = ColorStyle.point
        
        return config
    }
}
