//
//  ImageChatCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 6/30/24.
//

import UIKit
import SnapKit

final class ImageChatCollectionViewCell: BaseCollectionViewCell {
    
    let chatImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(chatImageView)
    }
    
    override func configureConstraints() {
        chatImageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
}
