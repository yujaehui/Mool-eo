//
//  ProfileView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/17/24.
//

import UIKit
import SnapKit

enum SectionType: CaseIterable {
    case info
    case product
    
    func makeSection() -> Section {
        switch self {
        case .info: return ProfileInfoSection()
        case .product: return ProfileProductSection()
        }
    }
}

class ProfileView: BaseView {
    
    lazy var collectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            return SectionType.allCases[sectionIndex].makeSection().layoutSection()
        }
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(ProfileInfoCollectionViewCell.self, forCellWithReuseIdentifier: ProfileInfoCollectionViewCell.identifier)
        collectionView.register(ProductPostListCollectionViewCell.self, forCellWithReuseIdentifier: ProductPostListCollectionViewCell.identifier)
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
