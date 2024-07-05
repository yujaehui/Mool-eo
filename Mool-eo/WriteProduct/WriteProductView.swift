//
//  WriteProductView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import UIKit
import SnapKit

final class WriteProductView: BaseView {

    let scrollView = UIScrollView()
    
    let writeProductPostContentView = WriteProductContentView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.contentSize = writeProductPostContentView.bounds.size
    }
    
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
}
