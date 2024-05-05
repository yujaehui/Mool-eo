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

class PostListViewController: BaseViewController {
    
    deinit {
        print("‼️PostListViewController Deinit‼️")
    }
    
    let viewModel = PostListViewModel()
    let postListView = PostListView()
    
    var postBoard: PostBoardType = .free
    lazy var reload = BehaviorSubject<PostBoardType>(value: postBoard)
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func bind() {
        sections.bind(to: postListView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        let reload = reload
        let postWriteButtonTap = postListView.postWriteButton.rx.tap.asObservable()
        let modelSelected = postListView.tableView.rx.modelSelected(PostModel.self).asObservable()
        let itemSelected = postListView.tableView.rx.itemSelected.asObservable()
        let prefetch = postListView.tableView.rx.prefetchRows.asObservable()
        let input = PostListViewModel.Input(reload: reload, postWriteButtonTap: postWriteButtonTap, modelSelected: modelSelected, itemSelected: itemSelected, lastRow: lastRow, prefetch: prefetch, postBoard: postBoard, nextCursor: nextCursor)
        
        let output = viewModel.transform(input: input)
        
        output.postList.bind(with: self) { owner, value in
            owner.sections.onNext([PostListSectionModel(items: value.data)])
            guard value.nextCursor != "0" else { return }
            owner.nextCursor.onNext(value.nextCursor)
            let lastSection = owner.postListView.tableView.numberOfSections - 1
            let lastRow = owner.postListView.tableView.numberOfRows(inSection: lastSection) - 1
            owner.lastRow.onNext(lastRow)
        }.disposed(by: disposeBag)
        
        output.nextPostList.bind(with: self) { owner, value in
            owner.sections
                .take(1)
                .subscribe(onNext: { currentSections in
                    var updatedSections = currentSections
                    updatedSections.append(PostListSectionModel(items: value.data))
                    owner.sections.onNext(updatedSections)
                    owner.postListView.tableView.reloadData()
                    guard value.nextCursor != "0" else { return }
                    owner.nextCursor.onNext(value.nextCursor)
                })
                .disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
        
        output.postWriteButtonTap.drive(with: self) { owner, _ in
            let vc = WritePostViewController()
            vc.type = .upload
            vc.postBoard = owner.postBoard
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            owner.present(nav, animated: true)
        }.disposed(by: disposeBag)
        
        // 특정 게시글 셀을 선택하면, 해당 게시글로 이동
        output.post.drive(with: self) { owner, value in
            let vc = PostDetailViewController()
            vc.postBoard = owner.postBoard
            vc.postId = value
            vc.userId = UserDefaultsManager.userId!
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxTableViewSectionedReloadDataSource<PostListSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<PostListSectionModel> { dataSource, tableView, indexPath, item in
            if item.files.isEmpty { // 이미지가 없는 게시글일 경우
                let cell = tableView.dequeueReusableCell(withIdentifier: PostListWithoutImageTableViewCell.identifier, for: indexPath) as! PostListWithoutImageTableViewCell
                cell.configureCell(item: item)
                cell.profileStackView.rx.tapGesture()
                    .when(.recognized)
                    .bind(with: self) { owner, value in
                        if item.creator.userID != UserDefaultsManager.userId {
                            let vc = OtherUserProfileViewController()
                            vc.userId = item.creator.userID
                            owner.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            let vc = ProfileViewController()
                            owner.navigationController?.pushViewController(vc, animated: true)
                        }
                    }.disposed(by: cell.disposeBag)
                return cell
            } else { // 이미지가 있는 게시글일 경우
                let cell = tableView.dequeueReusableCell(withIdentifier: PostListTableViewCell.identifier, for: indexPath) as! PostListTableViewCell
                cell.configureCell(item: item)
                cell.profileStackView.rx.tapGesture()
                    .when(.recognized)
                    .bind(with: self) { owner, value in
                        if item.creator.userID != UserDefaultsManager.userId {
                            let vc = OtherUserProfileViewController()
                            vc.userId = item.creator.userID
                            owner.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            let vc = ProfileViewController()
                            owner.navigationController?.pushViewController(vc, animated: true)
                        }
                    }.disposed(by: cell.disposeBag)
                return cell
            }
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
            if let postBoard = noti.object as? PostBoardType {
                owner.reload.onNext(postBoard)
            }
        }
        .disposed(by: disposeBag)
    }
}


