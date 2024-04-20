//
//  WritePostView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import UIKit

class WritePostView: BaseView {
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    let writePostBoxView = WritePostBoxView()
    
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
