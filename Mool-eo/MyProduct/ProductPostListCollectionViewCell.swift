//
//  ProductPostListCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import UIKit
import SnapKit

class ProductCollectionViewCell: BaseCollectionViewCell {
    
    let productImageView: PostImageView = {
        let imageView = PostImageView(frame: .zero)
        return imageView
    }()
    
    let productNameLabel: CustomLabel = {
        let label = CustomLabel(type: .contentBold)
        return label
    }()
    
    let priceLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
        return label
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(productImageView)
        contentView.addSubview(productNameLabel)
        contentView.addSubview(priceLabel)
    }
    
    override func configureConstraints() {
        productImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.horizontalEdges.equalTo(contentView)
            make.height.equalTo(productImageView.snp.width)
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
            make.bottom.lessThanOrEqualTo(contentView)
        }
    }
    
    func configureCell(item: PostListSectionModel.Item) {
        URLImageSettingManager.shared.setImageWithUrl(productImageView, urlString: item.files.first!)
        productNameLabel.text = item.title
        priceLabel.text = NumberFormatterManager.shared.formatCurrency(item.content1)
    }
}
