//
//  ProductPostListViewController.swift
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
    case market = "Mool-eo! Market"
    case postBoard = "Mool-eo! PostBoard"
    
}

class ProductPostListViewController: BaseViewController {
    
    deinit {
        print("‼️ProductPostListViewController Deinit‼️")
    }
    
    let viewModel = ProductPostListViewModel()
    let productPostListView = ProductPostListView()
    
    private let reload = BehaviorSubject<(ProductIdentifier, String)>(value: (.market, "전체"))
    private var sections = BehaviorSubject<[PostListSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    private let lastItem = PublishSubject<Int>()
    private let nextCursor = PublishSubject<String>()
    
    let category = BehaviorSubject<String>(value: "전체")
    let categoryList = Observable.just(["전체", "사료 및 간식", "의류 및 액세서리", "건강 관리", "하우스 및 운송", "장난감", "훈련 및 행동", "방충 및 방역", "배변용품", "미용용품", "식기 및 급수", "기타"])
    
    override func loadView() {
        self.view = productPostListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }

    
    override func setNav() {
//        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Mool-eo!"
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = ColorStyle.point
    }
    
    override func configureView() {
        categoryList.bind(to: productPostListView.collectionView.rx.items(cellIdentifier: ProductCategoryCollectionViewCell.identifier, cellType: ProductCategoryCollectionViewCell.self)) { (row, element, cell) in
            cell.categoryLabel.text = element
        }.disposed(by: disposeBag)
        sections.bind(to: productPostListView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    override func bind() {
        let reload = reload
        let postWriteButtonTap = productPostListView.postWirteButton.rx.tap.asObservable()
        let categoryModelSelected = productPostListView.collectionView.rx.modelSelected(String.self).asObservable()
        let categoryItemSelected = productPostListView.collectionView.rx.itemSelected.asObservable()
        let category = category
        let modelSelected = productPostListView.tableView.rx.modelSelected(PostModel.self).asObservable()
        let itemSelected = productPostListView.tableView.rx.itemSelected.asObservable()
        let prefetch = productPostListView.tableView.rx.prefetchRows.asObservable()
        
        let input = ProductPostListViewModel.Input(reload: reload, postWriteButtonTap: postWriteButtonTap, category: category, categoryModelSelected: categoryModelSelected, categoryItemSelected: categoryItemSelected, modelSelected: modelSelected, itemSelected: itemSelected, lastItem: lastItem, nextCursor: nextCursor, prefetch: prefetch)
        
        let output = viewModel.transform(input: input)

        output.productPostList.bind(with: self) { owner, value in
            owner.sections.onNext([PostListSectionModel(items: value.data)])
            owner.productPostListView.tableView.reloadData()
            guard value.nextCursor != "0" else { return }
            owner.nextCursor.onNext(value.nextCursor)
            let lastSection = owner.productPostListView.tableView.numberOfSections - 1
            let lastItem = owner.productPostListView.tableView.numberOfRows(inSection: lastSection) - 1
            owner.lastItem.onNext(lastItem)
        }.disposed(by: disposeBag)
        
        output.nextProductPostList.bind(with: self) { owner, value in
            owner.sections
                .take(1)
                .subscribe { currentSections in
                    var updatedSections = currentSections
                    updatedSections.append(PostListSectionModel(items: value.data))
                    owner.sections.onNext(updatedSections)
                    guard value.nextCursor != "0" else { return }
                    owner.nextCursor.onNext(value.nextCursor)
                    let lastSection = owner.productPostListView.tableView.numberOfSections - 1
                    let lastItem = owner.productPostListView.tableView.numberOfRows(inSection: lastSection) - 1
                    owner.lastItem.onNext(lastItem)
                }.disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
        
        output.postWriteButtonTap.drive(with: self) { owner, _ in
            let vc = WriteProductPostViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            owner.present(nav, animated: true)
        }.disposed(by: disposeBag)
        
        // 특정 게시글 셀을 선택하면, 해당 게시글로 이동
        output.productPost.bind(with: self) { owner, value in
            let vc = ProductPostDetailViewController()
            vc.postId = value.postId
            vc.accessType = UserDefaultsManager.userId == value.creator.userId ? .me : .other
            vc.hidesBottomBarWhenPushed = true
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.productPostListView)
        }.disposed(by: disposeBag)
        
        output.selectedCategory.bind(with: self) { owner, value in
            owner.category.onNext(value)
            owner.reload.onNext((ProductIdentifier.market, value))
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxTableViewSectionedReloadDataSource<PostListSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<PostListSectionModel> { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: ProdcutPostListTableViewCell.identifier, for: indexPath) as! ProdcutPostListTableViewCell
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
            owner.reload.onNext((ProductIdentifier.market, "전체"))
        }
        .disposed(by: disposeBag)
    }
}
