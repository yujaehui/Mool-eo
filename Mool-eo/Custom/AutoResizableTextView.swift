//
//  AutoResizableTextView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/29/24.
//

import UIKit

class AutoResizableTextView: UITextView {
    
    let maxHeight: CGFloat = 120
    
    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let size = CGSize(width: self.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        let newSize = self.sizeThatFits(size)
        let height = min(newSize.height, maxHeight)
        isScrollEnabled = newSize.height > maxHeight
        return CGSize(width: newSize.width, height: height)
    }
}
