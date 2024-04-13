//
//  PostBoardCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import UIKit
import SnapKit

class PostBoardCollectionViewCell: BaseCollectionViewCell {
    let titleLabel: CustomLabel = {
        let label = CustomLabel(type: .titleBold)
        return label
    }()
    
    let pointImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star.fill")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        layer.cornerRadius = 20
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureHierarchy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(pointImageView)
    }
    
    override func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(contentView).inset(20)
        }
        
        pointImageView.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(contentView).inset(20)
            make.size.equalTo(50)
        }
    }
    
    func configureCell(element: PostBoardType) {
        titleLabel.text = element.rawValue
    }
}
