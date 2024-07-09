//
//  LikeProductCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import UIKit
import SnapKit

final class LikeProductCollectionViewCell: BaseCollectionViewCell {
    
    let productImageView = PostImageView(frame: .zero)
    
    let productNameLabel = CustomLabel(type: .contentBold)
    
    let productPriceLabel = CustomLabel(type: .content)
    
    override func configureHierarchy() {
        contentView.addSubview(productImageView)
        contentView.addSubview(productNameLabel)
        contentView.addSubview(productPriceLabel)
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
        
        productPriceLabel.snp.makeConstraints { make in
            make.top.equalTo(productNameLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(contentView).inset(10)
            make.height.equalTo(20)
            make.bottom.equalTo(contentView)
        }
    }
    
    func configureCell(item: PostListSectionModel.Item) {
        URLImageSettingManager.shared.setImageWithUrl(productImageView, urlString: item.files.first!)
        productNameLabel.text = item.title
        productPriceLabel.text = NumberFormatterManager.shared.formatCurrencyString(item.content1)
    }
}
