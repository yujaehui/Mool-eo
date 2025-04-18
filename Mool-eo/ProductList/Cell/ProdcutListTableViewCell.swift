//
//  ProdcutListTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/12/24.
//

import UIKit
import SnapKit

final class ProdcutListTableViewCell: BaseTableViewCell {
    
    let productImageView: PostImageView = {
        let imageView = PostImageView(frame: .zero)
        return imageView
    }()
    
    let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 10
        return stackView
    }()
    
    let productNameLabel: CustomLabel = {
        let label = CustomLabel(type: .titleBold)
        label.numberOfLines = 1
        return label
    }()
    
    let productPriceLabel: CustomLabel = {
        let label = CustomLabel(type: .contentBold)
        label.numberOfLines = 1
        return label
    }()
    
    let productDetailLabel: CustomLabel = {
        let label = CustomLabel(type: .subContent)
        label.numberOfLines = 0
        return label
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(productImageView)
        contentView.addSubview(labelStackView)
        labelStackView.addArrangedSubview(productNameLabel)
        labelStackView.addArrangedSubview(productPriceLabel)
        labelStackView.addArrangedSubview(productDetailLabel)
    }
    
    override func configureConstraints() {
        productImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.leading.equalTo(contentView).inset(20)
            make.size.equalTo(120)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
        
        labelStackView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(productImageView.snp.verticalEdges)
            make.leading.equalTo(productImageView.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).inset(20)
        }
    }
    
    func configureCell(_ product: PostModel) {
        URLImageSettingManager.shared.setImageWithUrl(productImageView, urlString: product.files.first!, imageViewSize: .large)
        productNameLabel.text = product.title
        productPriceLabel.text = NumberFormatterManager.shared.formatCurrencyString(product.content1)
        productDetailLabel.text = HashtagManager.shared.removingTextAfterHash(product.content)
    }
}
