//
//  LikeProductListView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import UIKit
import SnapKit

class LikeProductListView: BaseView {
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.register(ProductPostListCollectionViewCell.self, forCellWithReuseIdentifier: ProductPostListCollectionViewCell.identifier)
        return collectionView
    }()
    
    override func configureHierarchy() {
        addSubview(collectionView)
    }
    
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 0
        let cellWidth = UIScreen.main.bounds.width - (spacing * 4)
        layout.itemSize = CGSize(width: cellWidth / 3, height: cellWidth / 3 + 60)
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        layout.minimumInteritemSpacing = spacing
        return layout
    }
}
