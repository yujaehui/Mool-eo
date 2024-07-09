//
//  EmptyCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/16/24.
//

import UIKit
import SnapKit

final class EmptyCollectionViewCell: BaseCollectionViewCell {
    let emptyLabel = CustomLabel(type: .contentBold)
    
    override func configureHierarchy() {
        contentView.addSubview(emptyLabel)
    }
    
    override func configureConstraints() {
        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(contentView)
        }
    }
}
