//
//  WritePostImageCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class WritePostImageCollectionViewCell: BaseCollectionViewCell {
    
    var disposeBag = DisposeBag()
    
    let selectImageView = CustomImageView(frame: .zero)
    let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = ColorStyle.caution
        return button
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        contentView.addSubview(selectImageView)
        contentView.addSubview(deleteButton)
    }
    
    override func configureConstraints() {
        selectImageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(selectImageView.snp.top)
            make.trailing.equalTo(selectImageView.snp.trailing)
            make.size.equalTo(30)
        }
    }
}
