//
//  ProfileProductListViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/2/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ProfileProductListViewController: BaseViewController {
    
    deinit { print("‼️ProfileProductListViewController Deinit‼️") }
    
    private let viewModel = ProfileProductListViewModel()
    private let profileProductListView = ProfileProductListView()
    
    private let reload = BehaviorSubject<ProductIdentifier>(value: (.product))
    private let lastItem = PublishSubject<Int>()
    private let nextCursor = PublishSubject<String>()
    
    private var sections = BehaviorSubject<[PostListSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    
    var nickname = ""
    var userId = ""
    
    override func loadView() {
        self.view = profileProductListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func setNav() {
        navigationItem.title = "\(nickname)님의 상품"
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = ColorStyle.point
    }
    
    override func configureView() {
        sections.bind(to: profileProductListView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    override func bind() {
        let reload = reload
        let modelSelected = profileProductListView.tableView.rx.modelSelected(PostModel.self).asObservable()
        let itemSelected = profileProductListView.tableView.rx.itemSelected.asObservable()
        let prefetch = profileProductListView.tableView.rx.prefetchRows.asObservable()
        
        let input = ProfileProductListViewModel.Input(reload: reload, userId: userId, modelSelected: modelSelected, itemSelected: itemSelected, lastItem: lastItem, nextCursor: nextCursor, prefetch: prefetch)
        
        let output = viewModel.transform(input: input)

        output.productPostList.bind(with: self) { owner, value in
            owner.sections.onNext([PostListSectionModel(items: value.data)])
            owner.profileProductListView.tableView.reloadData()
            guard value.nextCursor != "0" else { return }
            owner.nextCursor.onNext(value.nextCursor)
            let lastSection = owner.profileProductListView.tableView.numberOfSections - 1
            let lastItem = owner.profileProductListView.tableView.numberOfRows(inSection: lastSection) - 1
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
                    let lastSection = owner.profileProductListView.tableView.numberOfSections - 1
                    let lastItem = owner.profileProductListView.tableView.numberOfRows(inSection: lastSection) - 1
                    owner.lastItem.onNext(lastItem)
                }.disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
        
        output.productPost.bind(with: self) { owner, value in
            let vc = ProductDetailViewController()
            vc.postId = value.postId
            vc.accessType = UserDefaultsManager.userId == value.creator.userId ? .me : .other
            vc.hidesBottomBarWhenPushed = true
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.profileProductListView)
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
            owner.reload.onNext(ProductIdentifier.product)
        }
        .disposed(by: disposeBag)
    }
}

