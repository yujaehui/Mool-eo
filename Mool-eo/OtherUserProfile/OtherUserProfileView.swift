//
//  OtherUserProfileView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/2/24.
//

import UIKit
import SnapKit

class OtherUserProfileView: BaseView {
    
    var sections: [SectionType] = [.info]
    
    lazy var collectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            return self.sections[sectionIndex].makeSection().layoutSection()
        }
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(OtherUserProfileCollectionViewCell.self, forCellWithReuseIdentifier: OtherUserProfileCollectionViewCell.identifier)
        collectionView.register(PostListCollectionViewCell.self, forCellWithReuseIdentifier: PostListCollectionViewCell.identifier)
        collectionView.register(PostListWithoutImageCollectionViewCell.self, forCellWithReuseIdentifier: PostListWithoutImageCollectionViewCell.identifier)
        collectionView.register(ProductPostListCollectionViewCell.self, forCellWithReuseIdentifier: ProductPostListCollectionViewCell.identifier)
        collectionView.register(EmptyCollectionViewCell.self, forCellWithReuseIdentifier: EmptyCollectionViewCell.identifier)
        collectionView.register(ProductCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProductCollectionReusableView.identifier)
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
}
