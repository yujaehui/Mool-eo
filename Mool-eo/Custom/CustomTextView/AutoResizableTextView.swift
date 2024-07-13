//
//  AutoResizableTextView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/29/24.
//

import UIKit

class AutoResizableTextView: UITextView {
    
    var maxHeight: CGFloat?
    
    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let size = CGSize(width: self.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        let newSize = self.sizeThatFits(size)
        var height = max(40, newSize.height)
        if let maxHeight = maxHeight {
            height = min(height, maxHeight)
            isScrollEnabled = newSize.height > maxHeight
        }
        return CGSize(width: newSize.width, height: height)
    }
    
    convenience init(maxHeight: CGFloat?) {
        self.init(frame: .zero, textContainer: nil)
        self.maxHeight = maxHeight
    }
}
