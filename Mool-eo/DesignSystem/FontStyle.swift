//
//  FontStyle.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import UIKit

/// 사용방법
/// testLabel.font = FontStyle.titleBold
enum FontStyle {
    static let titleBold: UIFont = .boldSystemFont(ofSize: 18)
    static let title: UIFont = .systemFont(ofSize: 18)
    static let contentBold: UIFont = .boldSystemFont(ofSize: 16)
    static let content: UIFont = .systemFont(ofSize: 16)
    static let descriptionBold: UIFont = .boldSystemFont(ofSize: 14)
    static let description: UIFont = .systemFont(ofSize: 14)
}
