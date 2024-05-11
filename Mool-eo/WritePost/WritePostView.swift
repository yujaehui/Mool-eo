//
//  WritePostView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import UIKit
import SnapKit

class WritePostView: BaseView {
    
    let scrollView = UIScrollView()
    
    let writePostContentView = WritePostContentView()
    
    // Navigation
    let completeButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        return button
    }()
    
    // Navigation
    let cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "xmark")
        return button
    }()
    
    // ToolBar
    let imageAddButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "camera")
        button.tintColor = ColorStyle.point
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(writePostContentView)
    }
    
    override func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        writePostContentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.contentSize = writePostContentView.bounds.size
    }
}
