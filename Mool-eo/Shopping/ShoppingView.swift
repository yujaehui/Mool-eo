//
//  ShoppingView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import UIKit

enum ShoppingSectionType: CaseIterable {
    case payment
    case empty
    
    func makeSection() -> Section {
        switch self {
        case .payment: return PaymentSection()
        case .empty: return EmptySection()
        }
    }
}

class ShoppingView: BaseView {
    
    var sections: [ShoppingSectionType] = [.empty]
    
    lazy var collectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            return self.sections[sectionIndex].makeSection().layoutSection()
        }
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(PaymentCollectionViewCell.self, forCellWithReuseIdentifier: PaymentCollectionViewCell.identifier)
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
