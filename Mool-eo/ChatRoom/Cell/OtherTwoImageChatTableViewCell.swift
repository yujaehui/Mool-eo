//
//  OtherTwoImageChatTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/1/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class OtherTwoImageChatTableViewCell: BaseTableViewCell {
    var disposeBag = DisposeBag()
    
    let profileImageView = ProfileImageView(frame: .zero)
    
    let nicknameLabel: CustomLabel = {
        let label = CustomLabel(type: .subDescription)
        label.numberOfLines = 1
        return label
    }()
    
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
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(collectionView)
        contentView.addSubview(chatTimeLabel)
    }
    
    override func configureConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(5)
            make.leading.equalTo(contentView).inset(10)
            make.size.equalTo(40)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(5)
            make.leading.equalTo(profileImageView.snp.trailing).offset(5)
            make.trailing.lessThanOrEqualTo(contentView).inset(50)
            make.height.equalTo(10)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(5)
            make.leading.equalTo(profileImageView.snp.trailing).offset(5)
            make.width.equalTo(240)
            make.height.equalTo(120)
            make.bottom.equalTo(contentView).inset(5)
        }
        
        chatTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(collectionView.snp.trailing).offset(5)
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
    
    func configureCell(_ chat: Chat, lastSender: Sender?) {
        if let sender = lastSender {
            URLImageSettingManager.shared.setImageWithUrl(profileImageView, urlString: sender.profileImage)
            nicknameLabel.text = sender.nick
        }
        Observable.just(chat.filesArray).bind(to: collectionView.rx.items(cellIdentifier: ManyImageChatCollectionViewCell.identifier, cellType: ManyImageChatCollectionViewCell.self)) { (row, element, cell) in
            URLImageSettingManager.shared.setImageWithUrl(cell.chatImageView, urlString: element)
        }.disposed(by: disposeBag)
        chatTimeLabel.text = DateFormatterManager.shared.formatTimeToString(timeString: chat.createdAt)
    }
}
