//
//  ImageChatView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 6/30/24.
//

import UIKit
import SnapKit

final class ImageChatView: BaseView {
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = ColorStyle.mainBackground
        collectionView.register(ImageChatCollectionViewCell.self, forCellWithReuseIdentifier: ImageChatCollectionViewCell.identifier)
        return collectionView
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = ColorStyle.point
        pageControl.pageIndicatorTintColor = ColorStyle.subBackground
        return pageControl
    }()
    
    override func configureHierarchy() {
        addSubview(collectionView)
        addSubview(pageControl)
    }
    
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-10)
            make.centerX.equalToSuperview()
        }
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        return layout
    }
}
