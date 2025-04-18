//
//  ProductCategoryTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/17/24.
//

import UIKit
import SnapKit

final class ProductCategoryTableViewCell: BaseTableViewCell {
    let categoryLabel = CustomLabel(type: .contentBold)
    
    override func configureHierarchy() {
        contentView.addSubview(categoryLabel)
    }
    
    override func configureConstraints() {
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(20)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
    }
}
