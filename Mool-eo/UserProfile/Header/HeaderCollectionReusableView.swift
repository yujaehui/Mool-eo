//
//  HeaderCollectionReusableView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/14/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HeaderCollectionReusableView: BaseCollectionReusableView {
    
    var disposeBag = DisposeBag()
    
    let headerLabel: CustomLabel = {
        let label = CustomLabel(type: .titleBold)
        return label
    }()
    
    let seeMoreButton: UIButton = {
        let button = UIButton()
        button.configuration = .seeMore()
        return button
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        addSubview(headerLabel)
        addSubview(seeMoreButton)
    }
    
    override func configureConstraints() {
        headerLabel.snp.makeConstraints { make in
            make.centerY.equalTo(safeAreaLayoutGuide)
            make.leading.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(20)
        }
        
        seeMoreButton.snp.makeConstraints { make in
            make.centerY.equalTo(safeAreaLayoutGuide)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(20)
        }
    }
}
