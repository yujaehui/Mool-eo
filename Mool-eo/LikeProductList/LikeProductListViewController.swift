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

class LikeProductListViewController: BaseViewController {
    
    deinit {
        print("‼️LikeProductListViewController Deinit‼️")
    }
    
    let viewModel = LikeProductListViewModel()
    let likeProductListView = LikeProductListView()
    
    var reload = BehaviorSubject(value: ())
    
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
    
    override func bind() {
        sections.bind(to: likeProductListView.collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)

        let reload = reload
        let modelSelected = likeProductListView.collectionView.rx.modelSelected(PostModel.self).asObservable()
        let itemSelected = likeProductListView.collectionView.rx.itemSelected.asObservable()
        let prefetch = likeProductListView.collectionView.rx.prefetchItems.asObservable()
        let input = LikeProductListViewModel.Input(reload: reload, modelSelected: modelSelected, itemSelected: itemSelected, lastItem: lastItem, prefetch: prefetch, nextCursor: nextCursor)
        
        let output = viewModel.transform(input: input)
        
        output.likeProductList.bind(with: self) { owner, value in
            owner.sections.onNext([LikeListSectionModel(items: value.data)])
            guard value.nextCursor != "0" else { return }
            owner.nextCursor.onNext(value.nextCursor)
            let lastSection = owner.likeProductListView.collectionView.numberOfSections - 1
            let lastRow = owner.likeProductListView.collectionView.numberOfItems(inSection: lastSection) - 1
            owner.lastItem.onNext(lastRow)
        }.disposed(by: disposeBag)
        
        output.nextLikeProductList.bind(with: self) { owner, value in
            owner.sections
                .take(1)
                .subscribe(onNext: { currentSections in
                    var updatedSections = currentSections
                    updatedSections.append(LikeListSectionModel(items: value.data))
                    owner.sections.onNext(updatedSections)
                    owner.likeProductListView.collectionView.reloadData()
                    guard value.nextCursor != "0" else { return }
                    owner.nextCursor.onNext(value.nextCursor)
                })
                .disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
        
        output.post.drive(with: self) { owner, value in
            let vc = ProductPostDetailViewController()
            vc.postId = value
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.likeProductListView)
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<LikeListSectionModel> {
        let dataSource = RxCollectionViewSectionedReloadDataSource<LikeListSectionModel> { dataSource, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductPostListCollectionViewCell.identifier, for: indexPath) as! ProductPostListCollectionViewCell
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
}
