//
//  ProfileInfoSection.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/13/24.
//

import UIKit

struct ProfileInfoSection: Section {
    func layoutSection() -> NSCollectionLayoutSection? {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(210))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        
        return section
    }
}
