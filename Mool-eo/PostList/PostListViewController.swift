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

struct PostListSectionModel {
    var items: [PostModel]
}

extension PostListSectionModel: SectionModelType {
    typealias Item = PostModel
    
    init(original: PostListSectionModel, items: [PostModel]) {
        self = original
        self.items = items
    }
}

class PostListViewController: BaseViewController {
    
    let viewModel = PostListViewModel()
    let postListView = PostListView()
    
    var postBoard: PostBoardType = .free
    
    override func loadView() {
        self.view = postListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func bind() {
        let postBoardType = Observable.just(postBoard)
        let postWriteButtonTap = postListView.postWriteButton.rx.tap.asObservable()
        let modelSelected = postListView.tableView.rx.modelSelected(PostModel.self).asObservable()
        let itemSelected = postListView.tableView.rx.itemSelected.asObservable()
        let input = PostListViewModel.Input(postBoardType: postBoardType, postWriteButtonTap: postWriteButtonTap, modelSelected: modelSelected, itemSelected: itemSelected)
        
        let output = viewModel.transform(input: input)
        
        output.postList.bind(with: self) { owner, value in
            let sections: [PostListSectionModel] = [PostListSectionModel(items: value)]
            Observable.just(sections).bind(to: owner.postListView.tableView.rx.items(dataSource: owner.configureDataSource())).disposed(by: owner.disposeBag)
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
            vc.userId = UserDefaults.standard.string(forKey: "userId")!
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
                        if item.creator.userID != UserDefaults.standard.string(forKey: "userId") {
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
                        if item.creator.userID != UserDefaults.standard.string(forKey: "userId") {
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
}
