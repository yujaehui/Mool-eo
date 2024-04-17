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
        let label = CustomLabel(type: .colorTitleBold)
        label.text = "내 게시물"
        return label
    }()
    
    let lineView: LineView = {
       let view = LineView()
        view.backgroundColor = ColorStyle.point
        return view
    }()
    
    override func configureHierarchy() {
        addSubview(myPostLabel)
        addSubview(lineView)
    }
    
    override func configureConstraints() {
        myPostLabel.snp.makeConstraints { make in
            make.center.equalTo(safeAreaLayoutGuide)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(myPostLabel.snp.bottom).offset(5)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.width.equalTo(myPostLabel.snp.width)
            make.height.equalTo(3)
        }
    }
}
