//
//  ProfileCountView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/19/24.
//

import UIKit
import SnapKit

class ProfileCountView: BaseView {
    let countLabel: CustomLabel = {
        let label = CustomLabel(type: .contentBold)
        return label
    }()
    
    let contentLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
        label.text = "테스트"
        return label
    }()
    
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
