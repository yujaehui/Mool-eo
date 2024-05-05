//
//  WriteCommentView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/23/24.
//

import UIKit
import SnapKit

class WriteCommentView: BaseView {
    let commentTextView: AutoResizableTextView = {
        let textView = AutoResizableTextView(maxHeight: 120)
        textView.font = FontStyle.content
        textView.backgroundColor = ColorStyle.subBackground
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 10
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 35)
        return textView
    }()
    
    let commentUploadButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
        button.tintColor = ColorStyle.point
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(commentTextView)
        addSubview(commentUploadButton)
    }
    
    override func configureConstraints() {
        commentTextView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        commentUploadButton.snp.makeConstraints { make in
            make.trailing.equalTo(commentTextView.snp.trailing).inset(5)
            make.bottom.equalTo(commentTextView.snp.bottom).inset(5)
            make.size.equalTo(25)
        }
    }
}
