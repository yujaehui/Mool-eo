//
//  MyProductView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/27/24.
//

import UIKit

enum MyProductSectionType: CaseIterable {
    case product
    case empty
    
    func makeSection() -> Section {
        switch self {
        case .product: return ProductSection()
        case .empty: return EmptySection()
        }
    }
}

class MyProductView: BaseView {
    
    var sections: [MyProductSectionType] = [.empty]
    
    lazy var collectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            return self.sections[sectionIndex].makeSection().layoutSection()
        }
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: ProductCollectionViewCell.identifier)
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
