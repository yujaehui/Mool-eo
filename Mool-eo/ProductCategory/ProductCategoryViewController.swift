//
//  ProductCategoryViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/17/24.
//

import UIKit
import RxSwift
import RxCocoa

class ProductCategoryViewController: BaseViewController {
    
    let category = Observable.just(["사료 및 간식", "의류 및 액세서리", "건강 관리", "하우스 및 운송", "장난감", "훈련 및 행동", "방충 및 방역", "배변용품", "미용용품", "식기 및 급수", "기타"])
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
        category.bind(to: productCategoryView.tableView.rx.items(cellIdentifier: ProductCategoryTableViewCell.identifier, cellType: ProductCategoryTableViewCell.self)) { (row, element, cell) in
            cell.categoryLabel.text = element
        }.disposed(by: disposeBag)
    }
    
    override func bind() {
        let modelSelected = productCategoryView.tableView.rx.modelSelected(String.self).asObservable()
        let itemSelected = productCategoryView.tableView.rx.itemSelected.asObservable()
        let input = ProductCategoryViewModel.Input(modelSelected: modelSelected, itemSelected: itemSelected)
        
        let output = viewModel.transform(input: input)
        output.selectedCategory.bind(with: self) { owner, value in
            owner.selectedCategory?(value)
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
    }
}
