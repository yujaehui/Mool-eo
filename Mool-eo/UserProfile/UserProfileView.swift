//
//  UserProfileView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/1/24.
//

import UIKit
import SnapKit

enum UserProfileSectionType: CaseIterable {
    case info
    case post
    case product
    case more
    case empty
    
    func makeSection() -> Section {
        switch self {
        case .info: return UserInfoSection()
        case .post: return UserPostSection()
        case .product: return UserProductSection()
        case .more: return UserMoreSection()
        case .empty: return EmptySection()
        }
    }
}

final class UserProfileView: BaseView {
    var sections: [UserProfileSectionType] = [.info]
    
    lazy var collectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            return self.sections[sectionIndex].makeSection().layoutSection()
        }
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(UserProfileInfoCollectionViewCell.self, forCellWithReuseIdentifier: UserProfileInfoCollectionViewCell.identifier)
        collectionView.register(UserProfileProductCollectionViewCell.self, forCellWithReuseIdentifier: UserProfileProductCollectionViewCell.identifier)
        collectionView.register(UserProfilePostCollectionViewCell.self, forCellWithReuseIdentifier: UserProfilePostCollectionViewCell.identifier)
        collectionView.register(UserProfileMoreCollectionViewCell.self, forCellWithReuseIdentifier: UserProfileMoreCollectionViewCell.identifier)
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
