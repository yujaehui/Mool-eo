//
//  LineView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import UIKit

class LineView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ColorStyle.subBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
