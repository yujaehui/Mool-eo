//
//  UserProfileMoreCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/2/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum MoreType: String, CaseIterable {
    case like = "좋아요"
    case payment = "결제 내역"
    
    var image: UIImage {
        switch self {
        case .like: UIImage(systemName: "heart")!
        case .payment: UIImage(systemName: "creditcard")!
        }
    }
}

class UserProfileMoreCollectionViewCell: BaseCollectionViewCell {
    var disposeBag = DisposeBag()
    
    let moreImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = ColorStyle.point
        return imageView
    }()
    
    let moreLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
        return label
    }()
    
    let lineView = LineView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        contentView.addSubview(moreImageView)
        contentView.addSubview(moreLabel)
        contentView.addSubview(lineView)
    }
    
    override func configureConstraints() {
        moreImageView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView).inset(20)
            make.size.equalTo(20)
        }
        
        moreLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(moreImageView.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).inset(20)
        }
        
        lineView.snp.makeConstraints { make in
            make.bottom.equalTo(contentView)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(1)
        }
    }
    
    func configureCell(_ type: MoreType) {
        moreImageView.image = type.image
        moreLabel.text = type.rawValue
        
        if type == .payment {
            lineView.isHidden = true
        }
    }
}
