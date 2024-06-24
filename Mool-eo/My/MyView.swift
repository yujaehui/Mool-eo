//
//  MyView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/27/24.
//

import UIKit
import SnapKit

class MyView: BaseView {
    let scrollView: UIScrollView = {
       let view = UIScrollView()
        return view
    }()
    
    let contentView: UIView = {
       let view = UIView()
        return view
    }()
    
    let stickyHeaderView: MyInfoView = {
        let view = MyInfoView()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var tabbarCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.register(TabbarCollectionViewCell.self, forCellWithReuseIdentifier: TabbarCollectionViewCell.identifier)
        return collectionView
    }()
    
    let selectedTabView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 20, y: 55, width: UIScreen.main.bounds.width / 4, height: 5)
        view.backgroundColor = ColorStyle.point
        return view
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        return view
    }()
        
    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stickyHeaderView)
        contentView.addSubview(tabbarCollectionView)
        tabbarCollectionView.addSubview(selectedTabView)
        contentView.addSubview(bottomView)
    }
    
    override func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        
        stickyHeaderView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(140)
        }
        
        tabbarCollectionView.snp.makeConstraints { make in
            make.top.equalTo(stickyHeaderView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(tabbarCollectionView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1200)
        }
    }
    
    func configureCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let cellWidth = UIScreen.main.bounds.width
        layout.itemSize = CGSize(width: cellWidth / 4, height: 50)
        return layout
    }
}
