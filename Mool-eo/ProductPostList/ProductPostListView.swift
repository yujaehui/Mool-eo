//
//  ProductPostListView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import UIKit
import SnapKit

class ProductPostListView: BaseView {
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ProdcutPostListTableViewCell.self, forCellReuseIdentifier: ProdcutPostListTableViewCell.identifier)
        return tableView
    }()
    
    let postWirteButton: UIButton = {
        let button = UIButton()
        button.configuration = .postAdd("상품 등록")
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(tableView)
        addSubview(postWirteButton)
    }
    
    override func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        
        postWirteButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(20)
        }
    }
}
