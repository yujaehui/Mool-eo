//
//  PostImageCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import UIKit
import SnapKit

class PostImageCollectionViewCell: BaseCollectionViewCell {
    
    let postImageView = CustomImageView(frame: .zero)
    
    override func configureHierarchy() {
        contentView.addSubview(postImageView)
    }
    
    override func configureConstraints() {
        postImageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
}
