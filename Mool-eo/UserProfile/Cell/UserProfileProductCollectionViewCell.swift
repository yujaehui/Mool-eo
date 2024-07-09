//
//  UserProfileProductCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/2/24.
//

import UIKit
import SnapKit

final class UserProfileProductCollectionViewCell: BaseCollectionViewCell {
    
    let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let productNameLabel = CustomLabel(type: .contentBold)
    
    let priceLabel = CustomLabel(type: .content)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = ColorStyle.mainBackground
        contentView.layer.shadowOffset = .init(width: 2.5, height: 2.5)
        contentView.layer.shadowOpacity = 0.75
        contentView.layer.shadowColor = ColorStyle.subBackground.cgColor
        contentView.layer.shadowRadius = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureHierarchy() {
        contentView.addSubview(productImageView)
        contentView.addSubview(productNameLabel)
        contentView.addSubview(priceLabel)
    }
    
    override func configureConstraints() {
        productImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.horizontalEdges.equalTo(contentView)
        }
        
        productNameLabel.snp.makeConstraints { make in
            make.top.equalTo(productImageView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(10)
            make.height.equalTo(20)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(productNameLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(contentView).inset(10)
            make.height.equalTo(20)
            make.bottom.equalTo(contentView).inset(10)
        }
    }
    
    func configureCell(item: PostListSectionModel.Item) {
        URLImageSettingManager.shared.setImageWithUrl(productImageView, urlString: item.files.first!)
        productNameLabel.text = item.title
        priceLabel.text = NumberFormatterManager.shared.formatCurrencyString(item.content1)
    }
}
