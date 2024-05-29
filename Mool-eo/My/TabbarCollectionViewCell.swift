//
//  TabbarCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/25/24.
//

import UIKit
import SnapKit

class TabbarCollectionViewCell: BaseCollectionViewCell {
    let tabLabel: CustomLabel = {
        let label = CustomLabel(type: .contentBold)
        label.textAlignment = .center
        return label
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(tabLabel)
    }
    
    override func configureConstraints() {
        tabLabel.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
}
