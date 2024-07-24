//
//  MyTwoImageChatTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/1/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MyTwoImageChatTableViewCell: BaseTableViewCell {
    var disposeBag = DisposeBag()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.isUserInteractionEnabled = false
        collectionView.register(ManyImageChatCollectionViewCell.self, forCellWithReuseIdentifier: ManyImageChatCollectionViewCell.identifier)
        return collectionView
    }()
    
    let chatTimeLabel = CustomLabel(type: .subDescription)
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        contentView.addSubview(collectionView)
        contentView.addSubview(chatTimeLabel)
    }
    
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(contentView).inset(10)
            make.trailing.equalTo(contentView).inset(10)
            make.width.equalTo(240)
            make.height.equalTo(120)
        }
        
        chatTimeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(collectionView.snp.leading).offset(-5)
            make.bottom.equalTo(collectionView.snp.bottom)
        }
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        return layout
    }
    
    func configureCell(_ chat: Chat, showTime: Bool) {
        Observable.just(chat.filesArray).bind(to: collectionView.rx.items(cellIdentifier: ManyImageChatCollectionViewCell.identifier, cellType: ManyImageChatCollectionViewCell.self)) { (row, element, cell) in
            URLImageSettingManager.shared.setImageWithUrl(cell.chatImageView, urlString: element, imageViewSize: .large)
        }.disposed(by: disposeBag)
        chatTimeLabel.text = DateFormatterManager.shared.formatTimeToString(timeString: chat.createdAt)
        chatTimeLabel.isHidden = !showTime
    }
}
