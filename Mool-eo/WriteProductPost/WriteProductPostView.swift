//
//  WriteProductPostView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import UIKit
import SnapKit

class WriteProductPostView: BaseView {
    
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
    
    let scrollView = UIScrollView()
    
    let writeProductPostContentView = WriteProductPostContentView()
    
    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(writeProductPostContentView)
    }
    
    override func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        writeProductPostContentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.contentSize = writeProductPostContentView.bounds.size
    }
}
