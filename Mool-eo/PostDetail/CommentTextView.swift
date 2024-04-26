//
//  CommentTextView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/23/24.
//

import UIKit
import SnapKit

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

class CommentTextView: BaseView {
    let textView: AutoResizableTextView = {
        let textView = AutoResizableTextView()
        textView.font = FontStyle.content
        textView.backgroundColor = ColorStyle.subBackground
        return textView
    }()
    
    override func configureHierarchy() {
        addSubview(textView)
    }
    
    override func configureConstraints() {
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        }
    }
}
