//
//  ProductPostListView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import UIKit
import SnapKit

class ProductPostListView: BaseView {
    let pinterestLayout = PinterestLayout()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: pinterestLayout)
        collectionView.register(ProductPostListCollectionViewCell.self, forCellWithReuseIdentifier: ProductPostListCollectionViewCell.identifier)
        return collectionView
    }()
    
    let productPostWriteButton: UIButton = {
        let button = UIButton()
        button.configuration = .capsule2("상품 등록")
        return button
    }()

    override func configureHierarchy() {
        addSubview(collectionView)
        addSubview(productPostWriteButton)
    }
    
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(5)
        }
        
        productPostWriteButton.snp.makeConstraints { make in
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
        }
    }
}
