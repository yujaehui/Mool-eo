//
//  ProductListViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Toast
import Kingfisher

enum ProductIdentifier: String {
    case product = "Mool-eo! Market"
    case post = "Mool-eo! PostBoard"
}

enum Category: String, CaseIterable {
    case all = "전체"
    case feed = "사료 및 간식"
    case clothing = "의류 및 액세서리"
    case house = "하우스 및 운송"
    case toy = "장난감"
    case training = "훈련 및 행동"
    case insectRepellent = "방충 및 방역"
    case toiletries = "배변용품"
    case beautySupplies = "미용용품"
    case tableware = "식기 및 급수"
    case etc = "기타"
}

final class ProductListViewController: BaseViewController {
    
    deinit { print("‼️ProductListViewController Deinit‼️") }
    
    private let viewModel = ProductListViewModel()
    private let productListView = ProductListView()
    
    private let reload = BehaviorSubject<Void>(value: ())
    
    private let lastItem = PublishSubject<Int>()
    private let nextCursor = PublishSubject<String>()
    
    private let categoryList = BehaviorSubject<[String]>(value: Category.allCases.map { $0.rawValue })
    private var sections = BehaviorSubject<[PostListSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    
    override func loadView() {
        self.view = productListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func setNav() {
        navigationItem.title = "Mool-eo!"
    }
    
    override func configureView() {
        categoryList
            .bind(to: productListView.collectionView.rx.items(cellIdentifier: ProductCategoryCollectionViewCell.identifier, cellType: ProductCategoryCollectionViewCell.self)) { (row, element, cell) in
            cell.categoryLabel.text = element
        }.disposed(by: disposeBag)
        
        sections
            .bind(to: productListView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    override func bind() {
        let input = ProductListViewModel.Input(
            categoryModelSelected: productListView.collectionView.rx.modelSelected(String.self).asObservable(),
            categoryItemSelected: productListView.collectionView.rx.itemSelected.asObservable(),
            reload: reload,
            lastItem: lastItem,
            nextCursor: nextCursor,
            prefetch: productListView.tableView.rx.prefetchRows.asObservable(),
            modelSelected: productListView.tableView.rx.modelSelected(PostModel.self).asObservable(),
            itemSelected: productListView.tableView.rx.itemSelected.asObservable(),
            productWriteButtonTap: productListView.productWriteButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.selectedCategory.bind(with: self) { owner, value in
            owner.reload.onNext(())
        }.disposed(by: disposeBag)

        output.productList.bind(with: self) { owner, value in
            owner.sections.onNext([PostListSectionModel(items: value.data)])
            owner.updatePagination(value)
        }.disposed(by: disposeBag)
        
        output.nextProductList.bind(with: self) { owner, value in
            owner.sections
                .take(1)
                .subscribe { currentSections in
                    var updatedSections = currentSections
                    updatedSections.append(PostListSectionModel(items: value.data))
                    owner.sections.onNext(updatedSections)
                    owner.updatePagination(value)
                }.disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.productListView)
        }.disposed(by: disposeBag)
        
        output.productDetail.bind(with: self) { owner, value in
            let vc = ProductDetailViewController()
            vc.postId = value.postId
            vc.accessType = UserDefaultsManager.userId == value.creator.userId ? .me : .other
            vc.hidesBottomBarWhenPushed = true
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        output.productWriteButtonTap.drive(with: self) { owner, _ in
            let vc = WriteProductViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            owner.present(nav, animated: true)
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxTableViewSectionedReloadDataSource<PostListSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<PostListSectionModel> { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: ProdcutListTableViewCell.identifier, for: indexPath) as! ProdcutListTableViewCell
            cell.configureCell(item)
            return cell
        }
        return dataSource
    }
    
    private func registerObserver() {
        Observable.of(
            NotificationCenter.default.rx.notification(Notification.Name(Noti.writeProduct.rawValue)),
            NotificationCenter.default.rx.notification(Notification.Name(Noti.changeProduct.rawValue))
        )
        .merge()
        .take(until: self.rx.deallocated)
        .subscribe(with: self) { owner, noti in
            owner.reload.onNext(())
        }
        .disposed(by: disposeBag)
    }
    
    private func updatePagination(_ productList: PostListModel) {
        guard productList.nextCursor != "0" else { return }
        nextCursor.onNext(productList.nextCursor)
        let lastNumberSection = productListView.tableView.numberOfSections - 1
        let lastNumberRow = productListView.tableView.numberOfRows(inSection: lastNumberSection) - 1
        lastItem.onNext(lastNumberRow)
    }
}
