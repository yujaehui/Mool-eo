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
    
    private let reload = BehaviorSubject<Void>(value: ())
    private var sections = BehaviorSubject<[PostListSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    private let lastRow = PublishSubject<Int>()
    private let nextCursor = PublishSubject<String>()
    
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
        super.setNav()
        navigationItem.title = "\(nickname)님의 상품"
    }
    
    override func configureView() {
        sections.bind(to: profileProductListView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    override func bind() {
        let input = ProfileProductListViewModel.Input(
            reload: reload, 
            userId: userId,
            modelSelected: profileProductListView.tableView.rx.modelSelected(PostModel.self).asObservable(),
            itemSelected: profileProductListView.tableView.rx.itemSelected.asObservable(),
            lastRow: lastRow,
            nextCursor: nextCursor,
            prefetch: profileProductListView.tableView.rx.prefetchRows.asObservable()
        )
        
        let output = viewModel.transform(input: input)

        output.productList.bind(with: self) { owner, value in
            owner.configureSection(value)
        }.disposed(by: disposeBag)
        
        output.nextProductList.bind(with: self) { owner, value in
            owner.updateSection(value)
        }.disposed(by: disposeBag)
        
        output.productDetail.bind(with: self) { owner, value in
            owner.navigateToProductDetail(value)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.profileProductListView)
        }.disposed(by: disposeBag)
    }
    
    private func configureDataSource() -> RxTableViewSectionedReloadDataSource<PostListSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<PostListSectionModel> { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: ProdcutListTableViewCell.identifier, for: indexPath) as! ProdcutListTableViewCell
            cell.configureCell(item)
            return cell
        }
        return dataSource
    }
    
    private func configureSection(_ productList: PostListModel) {
        sections.onNext([PostListSectionModel(items: productList.data)])
        updatePagination(productList)
    }
    
    private func updateSection(_ productList: PostListModel) {
        sections
            .take(1)
            .subscribe(with: self) { owner, currentSections in
                var updateSections = currentSections
                updateSections.append(PostListSectionModel(items: productList.data))
                owner.sections.onNext(updateSections)
                owner.updatePagination(productList)
            }
            .disposed(by: disposeBag)
    }
    
    private func updatePagination(_ productList: PostListModel) {
        guard productList.nextCursor != "0" else { return }
        nextCursor.onNext(productList.nextCursor)
        let lastNumberSection = profileProductListView.tableView.numberOfSections - 1
        let lastNumberRow = profileProductListView.tableView.numberOfRows(inSection: lastNumberSection) - 1
        lastRow.onNext(lastNumberRow)
    }
    
    private func navigateToProductDetail(_ product: PostModel) {
        let vc = ProductDetailViewController()
        vc.postId = product.postId
        vc.accessType = UserDefaultsManager.userId == product.creator.userId ? .me : .other
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
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
}

