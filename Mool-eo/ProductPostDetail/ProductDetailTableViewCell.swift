//
//  ProductDetailTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/11/24.
//

import UIKit
import SnapKit

class ProductDetailTableViewCell: BaseTableViewCell {
        
    let detailLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
        label.numberOfLines = 0
        return label
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(detailLabel)
    }
    
    override func configureConstraints() {
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
    }
    
    func configureCell(_ postModel: PostModel) {
        detailLabel.text = postModel.content
    }
}
