//
//  CollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = ColorStyle.mainBackground
        configureHierarchy()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHierarchy() {}
    func configureConstraints() {}
}
