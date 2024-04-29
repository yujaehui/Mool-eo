//
//  WritePostView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import UIKit

class WritePostView: BaseView {
    
    let scrollView = UIScrollView()
    
    let writePostBoxView = WritePostBoxView()
    
    // Navigation
    let completeButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "완료"
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
        scrollView.addSubview(writePostBoxView)
    }
    
    override func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        writePostBoxView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
    }
}
