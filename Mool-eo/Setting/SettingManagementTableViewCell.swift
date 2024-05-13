//
//  SettingManagementTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/12/24.
//

import UIKit
import SnapKit

class SettingManagementTableViewCell: BaseTableViewCell {
    
    let managementLabel: CustomLabel = {
        let label = CustomLabel(type: .contentBold)
        label.textColor = ColorStyle.caution
        label.textAlignment = .center
        return label
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(managementLabel)
    }
    
    override func configureConstraints() {
        managementLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
            make.height.equalTo(20)
        }
    }
    
    func configureCell(_ text: String) {
        managementLabel.text = text
    }

}
