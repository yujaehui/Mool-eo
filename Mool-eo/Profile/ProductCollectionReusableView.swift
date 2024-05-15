//
//  ProductCollectionReusableView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/14/24.
//

import UIKit
import SnapKit

class ProductCollectionReusableView: BaseCollectionReusableView {
    let headerLabel: CustomLabel = {
        let label = CustomLabel(type: .titleBold)
        return label
    }()
    
    override func configureHierarchy() {
        addSubview(headerLabel)
    }
    
    override func configureConstraints() {
        headerLabel.snp.makeConstraints { make in
            make.verticalEdges.equalTo(safeAreaLayoutGuide).inset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(20)
        }
    }
}
