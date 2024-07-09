//
//  LikeProductListView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import UIKit
import SnapKit

final class LikeProductListView: BaseView {
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.register(LikeProductCollectionViewCell.self, forCellWithReuseIdentifier: LikeProductCollectionViewCell.identifier)
        return collectionView
    }()
    
    let emptyView = EmptyView()
    
    override func configureHierarchy() {
        addSubview(collectionView)
        addSubview(emptyView)
    }
    
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 10
        let cellWidth = UIScreen.main.bounds.width - (spacing * 4)
        layout.itemSize = CGSize(width: cellWidth / 3, height: cellWidth / 3 + 60)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumInteritemSpacing = spacing
        return layout
    }
}
