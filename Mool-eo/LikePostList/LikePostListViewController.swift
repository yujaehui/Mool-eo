//
//  LikePostListViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/11/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Toast

class LikePostListViewController: BaseViewController {
    
    deinit {
        print("‼️LikeProdcutListViewController Deinit‼️")
    }
    
    let viewModel = LikePostListViewModel()
    let likePostListView = LikePostListView()
    
    var reload = BehaviorSubject(value: ())
    
    private var sections = BehaviorSubject<[LikeListSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    
    private let lastRow = PublishSubject<Int>()
    private let nextCursor = PublishSubject<String>()
    
    override func loadView() {
        self.view = likePostListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func bind() {
        sections.bind(to: likePostListView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        let reload = reload
        let modelSelected = likePostListView.tableView.rx.modelSelected(PostModel.self).asObservable()
        let itemSelected = likePostListView.tableView.rx.itemSelected.asObservable()
        let prefetch = likePostListView.tableView.rx.prefetchRows.asObservable()
        let input = LikePostListViewModel.Input(reload: reload, modelSelected: modelSelected, itemSelected: itemSelected, lastRow: lastRow, prefetch: prefetch, nextCursor: nextCursor)
        
        let output = viewModel.transform(input: input)
        
        output.likePostList.bind(with: self) { owner, value in
            
            var sectionModels: [LikeListSectionModel] = []
            
            if !value.data.isEmpty {
                owner.likePostListView.tableView.isHidden = false
                owner.likePostListView.emptyView.isHidden = true
                let postSection = LikeListSectionModel(items: value.data)
                sectionModels.append(postSection)
            } else {
                owner.likePostListView.tableView.isHidden = true
                owner.likePostListView.emptyView.isHidden = false
                owner.likePostListView.emptyView.emptyLabel.text = "좋아요한 게시글이 없습니다"
            }
            
            owner.sections.onNext(sectionModels)
            
            guard value.nextCursor != "0" else { return }
            owner.nextCursor.onNext(value.nextCursor)
            let lastSection = owner.likePostListView.tableView.numberOfSections - 1
            let lastRow = owner.likePostListView.tableView.numberOfRows(inSection: lastSection) - 1
            owner.lastRow.onNext(lastRow)
        }.disposed(by: disposeBag)
        
        output.nextLikePostList.bind(with: self) { owner, value in
            owner.sections
                .take(1)
                .subscribe(onNext: { currentSections in
                    var updatedSections = currentSections
                    updatedSections.append(LikeListSectionModel(items: value.data))
                    owner.sections.onNext(updatedSections)
                    owner.likePostListView.tableView.reloadData()
                    guard value.nextCursor != "0" else { return }
                    owner.nextCursor.onNext(value.nextCursor)
                })
                .disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
        
        output.post.drive(with: self) { owner, value in
            let vc = PostDetailViewController()
            vc.postId = value
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.likePostListView)
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxTableViewSectionedReloadDataSource<LikeListSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<LikeListSectionModel> { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: LikePostTableViewCell.identifier, for: indexPath) as! LikePostTableViewCell
            cell.configureCell(myPost: item)
            return cell
        }
        return dataSource
    }
    
    private func registerObserver() {
        NotificationCenter.default.rx.notification(Notification.Name(Noti.changePost.rawValue))
            .take(until: self.rx.deallocated)
            .subscribe(with: self) { owner, _ in
                owner.reload.onNext(())
            }
            .disposed(by: disposeBag)
    }
}
