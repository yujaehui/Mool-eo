//
//  ColorStyle.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import UIKit

/// 사용방법
/// testLabel.textColor = ColorStyle.point
enum ColorStyle {
    static let point = UIColor.systemBrown
    static let mainText = UIColor.label
    static let subText = UIColor.secondaryLabel
    static let mainBackground = UIColor.systemBackground
    static let subBackground = UIColor.secondarySystemBackground
    static let caution = UIColor.systemPink
    static let clear = UIColor.clear
    static let placeholder = UIColor.placeholderText
}
