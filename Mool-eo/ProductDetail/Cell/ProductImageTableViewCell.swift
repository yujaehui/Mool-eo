//
//  ProductImageTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/11/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ProductImageTableViewCell: BaseTableViewCell {
    
    var disposeBag = DisposeBag()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.register(PostImageCollectionViewCell.self, forCellWithReuseIdentifier: PostImageCollectionViewCell.identifier)
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        contentView.addSubview(collectionView)
    }
    
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(contentView)
            make.height.equalTo(collectionView.snp.width)
            make.bottom.lessThanOrEqualTo(contentView)
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
    
    func configureCell(_ postModel: PostModel) {
        Observable.just(postModel.files).bind(to: collectionView.rx.items(cellIdentifier: PostImageCollectionViewCell.identifier, cellType: PostImageCollectionViewCell.self)) { (row, element, cell) in
            URLImageSettingManager.shared.setImageWithUrl(cell.postImageView, urlString: element)
            cell.postImageCountLabel.text = "\(row+1)/\(postModel.files.count)"
        }.disposed(by: disposeBag)
    }
}
