//
//  CommentTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CommentTableViewCell: BaseTableViewCell {
    
    var disposeBag = DisposeBag()
    
    let profileStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 10
        return stackView
    }()
    
    let profileImageView = ProfileImageView(frame: .zero)
    
    let nicknameLabel = CustomLabel(type: .descriptionBold)
    
    let commentLabel: CustomLabel = {
        let label = CustomLabel(type: .description)
        label.numberOfLines = 0
        return label
    }()
    
    let lineView = LineView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        contentView.addSubview(profileStackView)
        profileStackView.addArrangedSubview(profileImageView)
        profileStackView.addArrangedSubview(nicknameLabel)
        contentView.addSubview(commentLabel)
        contentView.addSubview(lineView)
    }
    
    override func configureConstraints() {
        profileStackView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(30)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(30)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView.snp.centerY)
        }
        
        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(profileStackView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(nicknameLabel.snp.horizontalEdges)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(commentLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(1)
            make.bottom.lessThanOrEqualTo(contentView).inset(20)
        }
    }
    
    func configureCell(comment: Comment) {
        URLImageSettingManager.shared.setImageWithUrl(profileImageView, urlString: comment.creator.profileImage)
        nicknameLabel.text = comment.creator.nick
        commentLabel.text = comment.content
    }
}
