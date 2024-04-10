//
//  CustomLabel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import UIKit

/// 사용방법
/// let testLabel = CustomLabel(type: .title)
class CustomLabel: UILabel {
    enum labelType {
        case title
        case titleBold
        case colorTitle
        case colorTitleBold
        case subTitle
        case subTitleBold
        
        case content
        case contentBold
        case colorContent
        case colorContentBold
        case subContent
        case subContentBold
        
        case description
        case descriptionBold
        case colorDescription
        case colorDescriptionBold
        case subDescription
        case subDescriptionBold
        
        var font: UIFont {
            switch self {
            case .title, .colorTitle, .subTitle: FontStyle.title
            case .titleBold, .colorTitleBold, .subTitleBold: FontStyle.titleBold
            case .content, .colorContent, .subContent: FontStyle.content
            case .contentBold, .colorContentBold, .subContentBold: FontStyle.contentBold
            case .description, .colorDescription, .subDescription: FontStyle.description
            case .descriptionBold, .colorDescriptionBold, .subDescriptionBold: FontStyle.descriptionBold
            }
        }
        
        var color: UIColor {
            switch self {
            case .title, .titleBold, .content, .contentBold, .description, .descriptionBold: ColorStyle.mainText
            case .colorTitle, .colorTitleBold, .colorContent, .colorContentBold, .colorDescription, .colorDescriptionBold: ColorStyle.point
            case .subTitle, .subTitleBold, .subContent, .subContentBold, .subDescription, .subDescriptionBold: ColorStyle.subText
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(type: labelType) {
        self.init(frame: .zero)
        configureView(type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(_ type: labelType) {
        textColor = type.color
        font = type.font
    }
}
