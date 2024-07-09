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

final class LikePostListViewController: BaseViewController {
    
    deinit { print("‼️LikeProdcutListViewController Deinit‼️") }
    
    let viewModel = LikePostListViewModel()
    let likePostListView = LikePostListView()
    
    private var reload = BehaviorSubject(value: ())
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
    
    override func configureView() {
        sections.bind(to: likePostListView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    override func bind() {
        let input = LikePostListViewModel.Input(
            reload: reload, 
            modelSelected: likePostListView.tableView.rx.modelSelected(PostModel.self).asObservable(),
            itemSelected: likePostListView.tableView.rx.itemSelected.asObservable(),
            lastRow: lastRow,
            nextCursor: nextCursor,
            prefetch: likePostListView.tableView.rx.prefetchRows.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.likePostList.bind(with: self) { owner, postList in
            owner.configureSection(postList)
            owner.updatePagination(postList)
        }.disposed(by: disposeBag)
        
        output.nextLikePostList.bind(with: self) { owner, postList in
            owner.updateSection(postList)
        }.disposed(by: disposeBag)
        
        output.postDetail.drive(with: self) { owner, value in
            let vc = PostDetailViewController()
            vc.postId = value
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.likePostListView)
        }.disposed(by: disposeBag)
    }
    
    private func configureDataSource() -> RxTableViewSectionedReloadDataSource<LikeListSectionModel> {
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
    
    private func configureSection(_ postList: PostListModel) {
        var sectionModels: [LikeListSectionModel] = []
        
        if !postList.data.isEmpty {
            likePostListView.tableView.isHidden = false
            likePostListView.emptyView.isHidden = true
            let postSection = LikeListSectionModel(items: postList.data)
            sectionModels.append(postSection)
        } else {
            likePostListView.tableView.isHidden = true
            likePostListView.emptyView.isHidden = false
            likePostListView.emptyView.emptyLabel.text = "좋아요한 게시글이 없습니다"
        }
        
        sections.onNext(sectionModels)
    }
    
    private func updateSection(_ postList: PostListModel) {
        sections
            .take(1)
            .subscribe(with: self) { owner, currentSections in
                var updateSections = currentSections
                updateSections.append(LikeListSectionModel(items: postList.data))
                owner.sections.onNext(updateSections)
                owner.updatePagination(postList)
            }
            .disposed(by: disposeBag)
    }
    
    private func updatePagination(_ postList: PostListModel) {
        guard postList.nextCursor != "0" else { return }
        nextCursor.onNext(postList.nextCursor)
        let lastNumberSection = likePostListView.tableView.numberOfSections - 1
        let lastNumberRow = likePostListView.tableView.numberOfRows(inSection: lastNumberSection) - 1
        lastRow.onNext(lastNumberRow)
    }
}
