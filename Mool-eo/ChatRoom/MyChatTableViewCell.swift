//
//  MyChatTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import UIKit
import SnapKit

class MyChatTableViewCell: BaseTableViewCell {
    let chatLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
        label.numberOfLines = 0
        return label
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(chatLabel)
    }
    
    override func configureConstraints() {
        chatLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(5)
            make.trailing.equalTo(contentView).inset(10)
            make.width.greaterThanOrEqualTo(100)
            make.bottom.lessThanOrEqualTo(contentView).inset(5)
        }
    }
}
