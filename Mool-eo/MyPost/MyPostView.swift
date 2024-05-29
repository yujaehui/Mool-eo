//
//  MyPostView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/27/24.
//

import UIKit

enum MyPostSectionType: CaseIterable {
    case post
    case empty
    
    func makeSection() -> Section {
        switch self {
        case .post: return PostSection()
        case .empty: return EmptySection()
        }
    }
}

class MyPostView: BaseView {
    
    var sections: [MyPostSectionType] = [.empty]
    
    lazy var collectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            return self.sections[sectionIndex].makeSection().layoutSection()
        }
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        collectionView.register(EmptyCollectionViewCell.self, forCellWithReuseIdentifier: EmptyCollectionViewCell.identifier)
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
