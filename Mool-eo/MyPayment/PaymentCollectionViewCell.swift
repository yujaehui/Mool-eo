//
//  PaymentCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import UIKit
import SnapKit

class PaymentCollectionViewCell: BaseCollectionViewCell {
    let productNameLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
        return label
    }()
    
    let priceLabel: CustomLabel = {
        let label = CustomLabel(type: .contentBold)
        return label
    }()
    
    let dateLabel: CustomLabel = {
        let label = CustomLabel(type: .subDescription)
        return label
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(productNameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(dateLabel)
    }
    
    override func configureConstraints() {
        productNameLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(20)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(productNameLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(20)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(20)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
    }
    
    func configureCell(_ data: Datum) {
        productNameLabel.text = data.productName
        priceLabel.text = NumberFormatterManager.shared.formatCurrency(data.price)
        dateLabel.text = DateFormatterManager.shared.formatDateToString(dateString: data.paidAt)
    }
}
