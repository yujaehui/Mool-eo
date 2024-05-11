//
//  ProductPostListCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import UIKit
import SnapKit

class ProductPostListCollectionViewCell: BaseCollectionViewCell {
    
    let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
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
            make.top.equalTo(contentView).inset(10)
            make.horizontalEdges.equalTo(contentView)
        }
        
        productNameLabel.snp.makeConstraints { make in
            make.top.equalTo(productImageView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(10)
            make.height.equalTo(20)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(productNameLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(10)
            make.height.equalTo(20)
            make.bottom.equalTo(contentView)
        }
    }
    
    func configureCell(item: PostListSectionModel.Item) {
        URLImageSettingManager.shared.setImageWithUrl(productImageView, urlString: item.files.first!)
        productNameLabel.text = item.title
        priceLabel.text = item.content1
    }
}
