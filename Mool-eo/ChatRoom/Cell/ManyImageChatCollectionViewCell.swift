//
//  ManyImageChatCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/1/24.
//

import UIKit
import SnapKit

final class ManyImageChatCollectionViewCell: BaseCollectionViewCell {
    let chatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(chatImageView)
    }
    
    override func configureConstraints() {
        chatImageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(2)
        }
    }
}
