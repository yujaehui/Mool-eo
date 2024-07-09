//
//  EmptyView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/17/24.
//

import UIKit
import SnapKit

final class EmptyView: BaseView {
    let emptyLabel: CustomLabel = {
        let label = CustomLabel(type: .titleBold)
        return label
    }()
    
    override func configureHierarchy() {
        addSubview(emptyLabel)
    }
    
    override func configureConstraints() {
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
