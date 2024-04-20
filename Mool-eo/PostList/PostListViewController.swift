//
//  PostListViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import RxDataSources

// 섹션에 대한 데이터 모델
struct PostListSectionModel {
    let title: String?
    var items: [postData]
}

// SectionModelType 프로토콜 준수
extension PostListSectionModel: SectionModelType {
    typealias Item = postData
    
    init(original: PostListSectionModel, items: [postData]) {
        self = original
        self.items = items
    }
}

class PostListViewController: BaseViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = PostListViewModel()
    let postListView = PostListView()
    
    var postBoard: PostBoardType = .free
    
    lazy var dataSource = configureDataSource()
    
    override func loadView() {
        self.view = postListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let viewDidLoadTrigger = Observable.just(postBoard)
        let postWriteButtonTap = postListView.postWriteButton.rx.tap.asObservable()
        let input = PostListViewModel.Input(viewDidLoadTrigger: viewDidLoadTrigger, postWriteButtonTap: postWriteButtonTap)
        
        let output = viewModel.transform(input: input)
        output.postList
            .map { posts in
                [PostListSectionModel(title: "Posts", items: posts)]
            }
            .bind(to: postListView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.postWriteButtonTap.bind(with: self) { owner, _ in
            let vc = WritePostViewController()
            vc.postBoard = owner.postBoard
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            owner.present(nav, animated: true)
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxTableViewSectionedReloadDataSource<PostListSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<PostListSectionModel>(
            configureCell: { dataSource, tableView, indexPath, item in
                if item.files.isEmpty {
                    // 비어 있는 files에 대한 셀 구성
                    let cell = tableView.dequeueReusableCell(withIdentifier: PostListWithoutImageTableViewCell.identifier, for: indexPath) as! PostListWithoutImageTableViewCell
                    let url = URL(string: APIKey.baseURL.rawValue + item.creator.profileImage)
                    let modifier = AnyModifier { request in
                        var urlRequest = request
                        urlRequest.headers = [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
                                              HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
                        return urlRequest
                    }
                    cell.profileImageView.kf.setImage(with: url, options: [.requestModifier(modifier)])
                    cell.nickNameLabel.text = item.creator.nick
                    cell.postBoardLabel.text = item.productID
                    cell.postTitleLabel.text = item.title
                    cell.postContentLabel.text = item.content
                    cell.likeCountLabel.text = "\(item.likes.count)"
                    cell.commentCountLabel.text = "\(item.comments.count)"
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: PostListTableViewCell.identifier, for: indexPath) as! PostListTableViewCell
                    let url = URL(string: APIKey.baseURL.rawValue + item.creator.profileImage)
                    let modifier = AnyModifier { request in
                        var urlRequest = request
                        urlRequest.headers = [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
                                              HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
                        return urlRequest
                    }
                    cell.profileImageView.kf.setImage(with: url, options: [.requestModifier(modifier)])
                    cell.nickNameLabel.text = item.creator.nick
                    cell.postBoardLabel.text = item.productID
                    cell.postTitleLabel.text = item.title
                    cell.postContentLabel.text = item.content
                    let postUrl = URL(string: APIKey.baseURL.rawValue + item.files.first!)
                    let postModifier = AnyModifier { request in
                        var urlRequest = request
                        urlRequest.headers = [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
                                              HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
                        return urlRequest
                    }
                    cell.postImageView.kf.setImage(with: postUrl, options: [.requestModifier(postModifier)])
                    cell.likeCountLabel.text = "\(item.likes.count)"
                    cell.commentCountLabel.text = "\(item.comments.count)"
                    return cell
                }
            }
        )
        return dataSource
    }
    
    
}
