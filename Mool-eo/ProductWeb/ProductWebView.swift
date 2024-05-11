//
//  ProductWebView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/11/24.
//

import UIKit
import SnapKit
import WebKit

class ProductWebView: BaseView {
    
    lazy var wkWebView: WKWebView = {
        var view = WKWebView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    override func configureHierarchy() {
        addSubview(wkWebView)
    }
    
    override func configureConstraints() {
        wkWebView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
}
