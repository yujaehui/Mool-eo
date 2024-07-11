//
//  ProfilePostListViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/16/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxGesture
import Toast

final class ProfilePostListViewController: BaseViewController {
    
    deinit { print("‼️ProfilePostListViewController Deinit‼️") }
    
    let viewModel = ProfilePostListViewModel()
    let profilePostListView = ProfilePostListView()
    
    private let reload = BehaviorSubject<Void>(value: ())
    private var sections = BehaviorSubject<[PostListSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    private let lastRow = PublishSubject<Int>()
    private let nextCursor = PublishSubject<String>()
    
    var nickname = ""
    var userId = ""
    
    override func loadView() {
        self.view = profilePostListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func setNav() {
        super.setNav()
        navigationItem.title = "\(nickname)의 게시글"
    }
    
    override func configureView() {
        sections.bind(to: profilePostListView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    override func bind() {
        let input = ProfilePostListViewModel.Input(
            reload: reload,
            userId: userId,
            modelSelected: profilePostListView.tableView.rx.modelSelected(PostModel.self).asObservable(),
            itemSelected: profilePostListView.tableView.rx.itemSelected.asObservable(),
            lastRow: lastRow,
            nextCursor: nextCursor,
            prefetch: profilePostListView.tableView.rx.prefetchRows.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.postList.bind(with: self) { owner, value in
            owner.configureSection(value)
        }.disposed(by: disposeBag)
        
        output.nextPostList.bind(with: self) { owner, value in
            owner.updateSection(value)
        }.disposed(by: disposeBag)
        
        output.postDetail.bind(with: self) { owner, value in
            owner.navigateToPostDetail(value)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.profilePostListView)
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxTableViewSectionedReloadDataSource<PostListSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<PostListSectionModel> { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: LikePostTableViewCell.identifier, for: indexPath) as! LikePostTableViewCell
            cell.configureCell(myPost: item)
            return cell
        }
        return dataSource
    }
    
    private func configureSection(_ postList: PostListModel) {
        sections.onNext([PostListSectionModel(items: postList.data)])
        updatePagination(postList)
    }
    
    private func updateSection(_ postList: PostListModel) {
        sections
            .take(1)
            .subscribe(with: self) { owner, currentSections in
                var updateSections = currentSections
                updateSections.append(PostListSectionModel(items: postList.data))
                owner.sections.onNext(updateSections)
                owner.updatePagination(postList)
            }
            .disposed(by: disposeBag)
    }
    
    private func updatePagination(_ postList: PostListModel) {
        guard postList.nextCursor != "0" else { return }
        nextCursor.onNext(postList.nextCursor)
        let lastNumberSection = profilePostListView.tableView.numberOfSections - 1
        let lastNumberRow = profilePostListView.tableView.numberOfRows(inSection: lastNumberSection) - 1
        lastRow.onNext(lastNumberRow)
    }
    
    private func navigateToPostDetail(_ post: PostModel) {
        let vc = PostDetailViewController()
        vc.postId = post.postId
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func registerObserver() {
        Observable.of(
            NotificationCenter.default.rx.notification(Notification.Name(Noti.writePost.rawValue)),
            NotificationCenter.default.rx.notification(Notification.Name(Noti.changePost.rawValue))
        )
        .merge()
        .take(until: self.rx.deallocated)
        .subscribe(with: self) { owner, noti in
            if let postBoard = noti.object as? ProductIdentifier {
                owner.reload.onNext(())
            }
        }
        .disposed(by: disposeBag)
    }
}
