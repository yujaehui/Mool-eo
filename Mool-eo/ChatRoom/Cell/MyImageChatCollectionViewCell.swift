//
//  MyImageChatCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 6/4/24.
//

import UIKit
import SnapKit

class MyImageChatCollectionViewCell: BaseCollectionViewCell {
    
    let chatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    override func configureHierarchy() {
        addSubview(chatImageView)
    }
    
    override func configureConstraints() {
        chatImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalToSuperview()
        }
    }
}
