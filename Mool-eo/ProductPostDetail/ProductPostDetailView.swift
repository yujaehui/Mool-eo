//
//  ProductPostDetailView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import UIKit
import SnapKit

class ProductPostDetailView: BaseView {
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ProductImageTableViewCell.self, forCellReuseIdentifier: ProductImageTableViewCell.identifier)
        tableView.register(ProductInfoTableViewCell.self, forCellReuseIdentifier: ProductInfoTableViewCell.identifier)
        tableView.register(ProductDetailTableViewCell.self, forCellReuseIdentifier: ProductDetailTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        return tableView
    }()
    
    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    let likeButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    let buyButton: UIButton = {
        let button = UIButton()
        button.configuration = .check("구매하기")
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(tableView)
        addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(likeButton)
        buttonStackView.addArrangedSubview(buyButton)
    }
    
    override func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(buttonStackView.snp.top).offset(-10)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
        }
        
        likeButton.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
    }
}
