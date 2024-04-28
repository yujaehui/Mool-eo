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
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
        textView.font = FontStyle.content
        textView.backgroundColor = ColorStyle.subBackground
        return textView
    }()
    
    let uploadButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.up"), for: .normal)
        button.tintColor = ColorStyle.point
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(textView)
        addSubview(uploadButton)
    }
    
    override func configureConstraints() {
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        uploadButton.snp.makeConstraints { make in
            make.trailing.equalTo(textView.snp.trailing).inset(5)
            make.bottom.equalTo(textView.snp.bottom).inset(5)
            make.size.equalTo(20)
        }
    }
}
