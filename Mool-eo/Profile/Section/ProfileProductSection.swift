//
//  ProfileProductSection.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/13/24.
//

import UIKit

struct ProfileProductSection: Section {
    func layoutSection() -> NSCollectionLayoutSection? {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(0.4))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.pinToVisibleBounds = true
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}
