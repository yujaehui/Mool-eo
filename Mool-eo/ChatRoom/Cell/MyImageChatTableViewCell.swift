//
//  MyImageChatTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 6/4/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MyImageChatTableViewCell: BaseTableViewCell {
    let chatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(chatImageView)
    }
    
    override func configureConstraints() {
        chatImageView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(contentView).inset(10)
            make.trailing.equalTo(contentView).inset(10)
            make.size.equalTo(200)
        }
    }
}
