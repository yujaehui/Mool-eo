//
//  OtherUserProfileView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/2/24.
//

import UIKit
import SnapKit

enum OtherUserProfileSectionType: CaseIterable {
    case info
    case product
    case post
    case empty
    
    func makeSection() -> Section {
        switch self {
        case .info: return UserInfoSection()
        case .product: return UserProductSection()
        case .post: return UserPostSection()
        case .empty: return EmptySection()
        }
    }
}

final class OtherUserProfileView: BaseView {
    
    var sections: [OtherUserProfileSectionType] = [.info]
    
    lazy var collectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            return self.sections[sectionIndex].makeSection().layoutSection()
        }
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(OtherUserProfileInfoCollectionViewCell.self, forCellWithReuseIdentifier: OtherUserProfileInfoCollectionViewCell.identifier)
        collectionView.register(UserProfileProductCollectionViewCell.self, forCellWithReuseIdentifier: UserProfileProductCollectionViewCell.identifier)
        collectionView.register(UserProfilePostCollectionViewCell.self, forCellWithReuseIdentifier: UserProfilePostCollectionViewCell.identifier)
        collectionView.register(EmptyCollectionViewCell.self, forCellWithReuseIdentifier: EmptyCollectionViewCell.identifier)
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.identifier)
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
