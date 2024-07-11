//
//  PostListViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxGesture
import Toast

final class PostListViewController: BaseViewController {
    
    deinit { print("‼️PostListViewController Deinit‼️") }
    
    let viewModel = PostListViewModel()
    let postListView = PostListView()
    
    lazy var reload = BehaviorSubject<Void>(value: ())
    
    private var sections = BehaviorSubject<[PostListSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    
    private let lastRow = PublishSubject<Int>()
    private let nextCursor = PublishSubject<String>()
    
    override func loadView() {
        self.view = postListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func setNav() {
        super.setNav()
        navigationItem.title = "게시글"
    }
    
    override func configureView() {
        sections
            .bind(to: postListView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    override func bind() {
        let input = PostListViewModel.Input(
            reload: reload,
            lastRow: lastRow,
            nextCursor: nextCursor,
            prefetch: postListView.tableView.rx.prefetchRows.asObservable(),
            modelSelected: postListView.tableView.rx.modelSelected(PostModel.self).asObservable(),
            itemSelected: postListView.tableView.rx.itemSelected.asObservable(),
            postWriteButtonTap: postListView.postWriteButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.postList.bind(with: self) { owner, value in
            owner.sections.onNext([PostListSectionModel(items: value.data)])
            owner.updatePagination(value)
        }.disposed(by: disposeBag)
        
        output.nextPostList.bind(with: self) { owner, value in
            owner.sections
                .take(1)
                .subscribe(with: self) { owner, currentSections in
                    var updatedSections = currentSections
                    updatedSections.append(PostListSectionModel(items: value.data))
                    owner.sections.onNext(updatedSections)
                    owner.updatePagination(value)
                }.disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
        
        output.postDetail.bind(with: self) { owner, value in
            let vc = PostDetailViewController()
            vc.postId = value.postId
            vc.accessType = UserDefaultsManager.userId! == value.creator.userId ? .me : .other
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        output.postWriteButtonTap.drive(with: self) { owner, _ in
            let vc = WritePostViewController()
            vc.type = .upload
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            owner.present(nav, animated: true)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.postListView)
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
                        vc.nickname = item.creator.nick
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
            if noti.object is ProductIdentifier {
                owner.reload.onNext(())
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func updatePagination(_ postList: PostListModel) {
        guard postList.nextCursor != "0" else { return }
        nextCursor.onNext(postList.nextCursor)
        let lastNumberSection = postListView.tableView.numberOfSections - 1
        let lastNumberRow = postListView.tableView.numberOfRows(inSection: lastNumberSection) - 1
        lastRow.onNext(lastNumberRow)
    }
}


