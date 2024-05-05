//
//  PostImageView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/29/24.
//

import UIKit

class PostImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.cornerRadius = 20
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
