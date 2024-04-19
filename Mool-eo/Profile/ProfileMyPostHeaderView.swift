//
//  ProfileMyPostHeaderView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/17/24.
//

import UIKit
import SnapKit

class ProfileMyPostHeaderView: BaseView {
    let myPostLabel: CustomLabel = {
        let label = CustomLabel(type: .titleBold)
        label.text = "내 게시물"
        return label
    }()
    
    override func configureHierarchy() {
        addSubview(myPostLabel)
    }
    
    override func configureConstraints() {
        myPostLabel.snp.makeConstraints { make in
            make.verticalEdges.equalTo(safeAreaLayoutGuide).inset(10)
            make.leading.equalTo(safeAreaLayoutGuide).inset(20)
        }
    }
}
