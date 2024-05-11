//
//  LargePostImageView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/5/24.
//

import UIKit

class LargePostImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .scaleAspectFit
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
