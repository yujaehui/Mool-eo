//
//  WritePostImageEditCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/3/24.
//

import UIKit
import SnapKit

final class WritePostImageEditCollectionViewCell: BaseCollectionViewCell {
    
    let selectImageView = PostImageView(frame: .zero)
    
    let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.subBackground.withAlphaComponent(0.8)
        return view
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(selectImageView)
        contentView.addSubview(overlayView)
    }
    
    override func configureConstraints() {
        selectImageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        
        overlayView.snp.makeConstraints { make in
            make.edges.equalTo(selectImageView)
        }
    }
}
