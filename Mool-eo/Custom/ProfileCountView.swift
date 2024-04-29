//
//  ProfileCountView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/19/24.
//

import UIKit
import SnapKit

enum ProfileCountType: String {
    case follower = "팔로워"
    case following = "팔로잉"
    case post = "게시글"
}

class ProfileCountView: BaseView {
    let countLabel: CustomLabel
    let contentLabel: CustomLabel
    let profileCountType: ProfileCountType
    
    init(frame: CGRect, profileCountType: ProfileCountType) {
        self.profileCountType = profileCountType
        self.countLabel = CustomLabel(type: .contentBold)
        self.contentLabel = CustomLabel(type: .content)
        self.contentLabel.text = profileCountType.rawValue
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureHierarchy() {
        addSubview(countLabel)
        addSubview(contentLabel)
    }
    
    override func configureConstraints() {
        countLabel.snp.makeConstraints { make in
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(20)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(countLabel.snp.bottom).offset(5)
            make.bottom.lessThanOrEqualTo(safeAreaLayoutGuide)
        }
    }
}
