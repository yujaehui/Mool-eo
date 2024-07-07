//
//  PostImageCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import UIKit
import SnapKit

final class PostImageCollectionViewCell: BaseCollectionViewCell {
    
    let postImageView = LargePostImageView(frame: .zero)
    
    let postImageCountLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
        label.textAlignment = .center
        label.backgroundColor = ColorStyle.subBackground.withAlphaComponent(0.8)
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        return label
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(postImageView)
        contentView.addSubview(postImageCountLabel)
    }
    
    override func configureConstraints() {
        postImageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        
        postImageCountLabel.snp.makeConstraints { make in
            make.top.equalTo(postImageView.snp.top).inset(10)
            make.trailing.equalTo(postImageView.snp.trailing).inset(10)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
    }
}
