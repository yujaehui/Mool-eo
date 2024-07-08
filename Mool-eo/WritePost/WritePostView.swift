//
//  WritePostView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import UIKit
import SnapKit

final class WritePostView: BaseView {
    
    let scrollView = UIScrollView()
    
    let writePostContentView = WritePostContentView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.contentSize = writePostContentView.bounds.size
    }
    
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
}
