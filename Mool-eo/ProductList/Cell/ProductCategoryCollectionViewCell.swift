//
//  ProductCategoryCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/17/24.
//

import UIKit
import SnapKit

final class ProductCategoryCollectionViewCell: BaseCollectionViewCell {
    
    let categoryLabel = CustomLabel(type: .description)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = ColorStyle.subBackground.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureHierarchy() {
        contentView.addSubview(categoryLabel)
    }
    
    override func configureConstraints() {
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.centerX.equalTo(contentView)
            make.height.equalTo(20)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
    }
}
