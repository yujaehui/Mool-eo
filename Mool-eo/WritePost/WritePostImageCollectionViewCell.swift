//
//  WritePostImageCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import UIKit
import SnapKit

class WritePostImageCollectionViewCell: BaseCollectionViewCell {
    let selectImageView = CustomImageView(frame: .zero)
    
    override func configureHierarchy() {
        contentView.addSubview(selectImageView)
    }
    
    override func configureConstraints() {
        selectImageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
}
