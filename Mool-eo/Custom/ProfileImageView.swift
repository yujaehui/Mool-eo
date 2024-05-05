//
//  ProfileImageView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/5/24.
//

import UIKit

class ProfileImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .scaleAspectFill
        clipsToBounds = true
        tintColor = ColorStyle.point
        backgroundColor = ColorStyle.subBackground
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
