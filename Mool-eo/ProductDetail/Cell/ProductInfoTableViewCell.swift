//
//  ProductInfoTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/11/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ProductInfoTableViewCell: BaseTableViewCell {
    
    var disposeBag = DisposeBag()
    
    let profileStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 10
        return stackView
    }()
    
    let profileImageView = ProfileImageView(frame: .zero)
    
    let nickNameLabel = CustomLabel(type: .descriptionBold)
    
    let productNameLabel = CustomLabel(type: .titleBold)
    
    let productPriceLabel = CustomLabel(type: .titleBold)
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        contentView.addSubview(profileStackView)
        profileStackView.addArrangedSubview(profileImageView)
        profileStackView.addArrangedSubview(nickNameLabel)
        contentView.addSubview(productNameLabel)
        contentView.addSubview(productPriceLabel)
    }
    
    override func configureConstraints() {
        profileStackView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(50)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(50)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView.snp.centerY)
        }
        
        productNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileStackView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        productPriceLabel.snp.makeConstraints { make in
            make.top.equalTo(productNameLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
    }
    
    func configureCell(_ postModel: PostModel) {
        nickNameLabel.text = postModel.creator.nick
        productNameLabel.text = postModel.title
        productPriceLabel.text = NumberFormatterManager.shared.formatCurrencyString(postModel.content1)
    }
}
