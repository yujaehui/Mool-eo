//
//  BaseView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import UIKit

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ColorStyle.mainBackground
        configureHierarchy()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHierarchy() {}
    func configureConstraints() {}
}
