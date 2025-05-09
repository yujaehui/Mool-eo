//
//  WriteContentView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/30/24.
//

import UIKit
import SnapKit

class WriteContentView: BaseView {
    let writeTextView: AutoResizableTextView = {
        let textView = AutoResizableTextView(maxHeight: 120)
        textView.font = FontStyle.content
        textView.backgroundColor = ColorStyle.subBackground
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 10
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 35)
        return textView
    }()
    
    let textUploadButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
        button.tintColor = ColorStyle.point
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(writeTextView)
        addSubview(textUploadButton)
    }
    
    override func configureConstraints() {
        writeTextView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
        }
        
        textUploadButton.snp.makeConstraints { make in
            make.trailing.equalTo(writeTextView.snp.trailing).inset(5)
            make.bottom.equalTo(writeTextView.snp.bottom).inset(5)
            make.size.equalTo(25)
        }
    }
}
