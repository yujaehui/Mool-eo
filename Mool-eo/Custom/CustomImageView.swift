//
//  CustomImageView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/29/24.
//

import UIKit

class CustomImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(type: TextFieldType) {
        self.init(frame: .zero)
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.cornerRadius = 20
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
