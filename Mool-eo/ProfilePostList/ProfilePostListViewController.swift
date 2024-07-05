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

class ProfilePostListViewController: BaseViewController {
    
    deinit {
        print("‼️PostListViewController Deinit‼️")
    }
    
    let viewModel = ProfilePostListViewModel()
    let profilePostListView = ProfilePostListView()
    
    var nickname = ""
    var userId = ""
    var postBoard: ProductIdentifier = .post
    lazy var reload = BehaviorSubject<ProductIdentifier>(value: postBoard)
    
    private var sections = BehaviorSubject<[PostListSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    
    private let lastRow = PublishSubject<Int>()
    private let nextCursor = PublishSubject<String>()
    
    override func loadView() {
        self.view = profilePostListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func setNav() {
        navigationItem.title = "\(nickname)의 게시글"
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = ColorStyle.point
    }
    
    override func bind() {
        sections.bind(to: profilePostListView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        let reload = reload
        let userId = userId
        let modelSelected = profilePostListView.tableView.rx.modelSelected(PostModel.self).asObservable()
        let itemSelected = profilePostListView.tableView.rx.itemSelected.asObservable()
        let prefetch = profilePostListView.tableView.rx.prefetchRows.asObservable()
        let input = ProfilePostListViewModel.Input(reload: reload, userId: userId, modelSelected: modelSelected, itemSelected: itemSelected, lastRow: lastRow, prefetch: prefetch, postBoard: postBoard, nextCursor: nextCursor)
        
        let output = viewModel.transform(input: input)
        
        output.postList.bind(with: self) { owner, value in
            owner.sections.onNext([PostListSectionModel(items: value.data)])
            guard value.nextCursor != "0" else { return }
            owner.nextCursor.onNext(value.nextCursor)
            let lastSection = owner.profilePostListView.tableView.numberOfSections - 1
            let lastRow = owner.profilePostListView.tableView.numberOfRows(inSection: lastSection) - 1
            owner.lastRow.onNext(lastRow)
        }.disposed(by: disposeBag)
        
        output.nextPostList.bind(with: self) { owner, value in
            owner.sections
                .take(1)
                .subscribe(onNext: { currentSections in
                    var updatedSections = currentSections
                    updatedSections.append(PostListSectionModel(items: value.data))
                    owner.sections.onNext(updatedSections)
                    owner.profilePostListView.tableView.reloadData()
                    guard value.nextCursor != "0" else { return }
                    owner.nextCursor.onNext(value.nextCursor)
                })
                .disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
        
        // 특정 게시글 셀을 선택하면, 해당 게시글로 이동
        output.post.drive(with: self) { owner, value in
            let vc = PostDetailViewController()
            vc.postBoard = owner.postBoard
            vc.postId = value
            vc.userId = UserDefaultsManager.userId!
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.profilePostListView)
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxTableViewSectionedReloadDataSource<PostListSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<PostListSectionModel> { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: PostListTableViewCell.identifier, for: indexPath) as! PostListTableViewCell
            cell.configureCell(item: item)
            cell.profileStackView.rx.tapGesture()
                .when(.recognized)
                .bind(with: self) { owner, value in
                    if item.creator.userId != UserDefaultsManager.userId {
                        let vc = OtherUserProfileViewController()
                        vc.userId = item.creator.userId
                        owner.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc = UserProfileViewController()
                        owner.navigationController?.pushViewController(vc, animated: true)
                    }
                }.disposed(by: cell.disposeBag)
            return cell
        }
        return dataSource
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
                owner.reload.onNext(postBoard)
            }
        }
        .disposed(by: disposeBag)
    }
}
