//
//  ProductCategoryViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/17/24.
//

import UIKit
import RxSwift
import RxCocoa

final class ProductCategoryViewController: BaseViewController {
    
    var selectedCategory: ((String) -> Void)?
    
    let viewModel = ProductCategoryViewModel()
    let productCategoryView = ProductCategoryView()
    
    override func loadView() {
        self.view = productCategoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setNav() {
        navigationItem.title = "카테고리"
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = ColorStyle.point
    }
    
    override func configureView() {
        Observable.just(Category.allCases.map { $0.rawValue }.filter { $0 != "전체" })
            .bind(to: productCategoryView.tableView.rx.items(cellIdentifier: ProductCategoryTableViewCell.identifier, cellType: ProductCategoryTableViewCell.self)) { (row, element, cell) in
            cell.categoryLabel.text = element
        }.disposed(by: disposeBag)
    }
    
    override func bind() {
        let input = ProductCategoryViewModel.Input(
            modelSelected: productCategoryView.tableView.rx.modelSelected(String.self).asObservable(),
            itemSelected: productCategoryView.tableView.rx.itemSelected.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.selectedCategory.bind(with: self) { owner, value in
            owner.selectedCategory?(value)
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
    }
}
