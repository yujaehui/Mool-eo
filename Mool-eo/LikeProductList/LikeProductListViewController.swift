//
//  LikeProductListViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Toast

final class LikeProductListViewController: BaseViewController {
    
    deinit { print("‼️LikeProductListViewController Deinit‼️") }
    
    let viewModel = LikeProductListViewModel()
    let likeProductListView = LikeProductListView()
    
    private var reload = BehaviorSubject(value: ())
    private var sections = BehaviorSubject<[LikeListSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    private let lastItem = PublishSubject<Int>()
    private let nextCursor = PublishSubject<String>()
    
    override func loadView() {
        self.view = likeProductListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func configureView() {
        sections.bind(to: likeProductListView.collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    override func bind() {
        let input = LikeProductListViewModel.Input(
            reload: reload, 
            modelSelected: likeProductListView.collectionView.rx.modelSelected(PostModel.self).asObservable(),
            itemSelected: likeProductListView.collectionView.rx.itemSelected.asObservable(),
            lastItem: lastItem,
            nextCursor: nextCursor,
            prefetch: likeProductListView.collectionView.rx.prefetchItems.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.likeProductList.bind(with: self) { owner, productList in            
            owner.configureSection(productList)
            owner.updatePagination(productList)
        }.disposed(by: disposeBag)
        
        output.nextLikeProductList.bind(with: self) { owner, productList in
            owner.updateSection(productList)
        }.disposed(by: disposeBag)
        
        output.productDetail.drive(with: self) { owner, value in
            let vc = ProductDetailViewController()
            vc.postId = value
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.likeProductListView)
        }.disposed(by: disposeBag)
    }
    
    private func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<LikeListSectionModel> {
        let dataSource = RxCollectionViewSectionedReloadDataSource<LikeListSectionModel> { dataSource, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LikeProductCollectionViewCell.identifier, for: indexPath) as! LikeProductCollectionViewCell
            cell.configureCell(item: item)
            return cell
        }
        return dataSource
    }
    
    private func registerObserver() {
        NotificationCenter.default.rx.notification(Notification.Name(Noti.changeProduct.rawValue))
            .take(until: self.rx.deallocated)
            .subscribe(with: self) { owner, _ in
                owner.reload.onNext(())
            }
            .disposed(by: disposeBag)
    }
    
    private func configureSection(_ productList: PostListModel) {
        var sectionModels: [LikeListSectionModel] = []
        
        if !productList.data.isEmpty {
            likeProductListView.collectionView.isHidden = false
            likeProductListView.emptyView.isHidden = true
            let postSection = LikeListSectionModel(items: productList.data)
            sectionModels.append(postSection)
        } else {
            likeProductListView.collectionView.isHidden = true
            likeProductListView.emptyView.isHidden = false
            likeProductListView.emptyView.emptyLabel.text = "좋아요한 상품이 없습니다"
        }
        
        sections.onNext(sectionModels)
    }
    
    private func updateSection(_ productList: PostListModel) {
        sections
            .take(1)
            .subscribe(with: self) { owner, currentSections in
                var updateSections = currentSections
                updateSections.append(LikeListSectionModel(items: productList.data))
                owner.sections.onNext(updateSections)
                owner.updatePagination(productList)
            }
            .disposed(by: disposeBag)
    }
    
    private func updatePagination(_ productList: PostListModel) {
        guard productList.nextCursor != "0" else { return }
        nextCursor.onNext(productList.nextCursor)
        let lastNumberSection = likeProductListView.collectionView.numberOfSections - 1
        let lastNumberItem = likeProductListView.collectionView.numberOfItems(inSection: lastNumberSection) - 1
        lastItem.onNext(lastNumberItem)
    }
}
