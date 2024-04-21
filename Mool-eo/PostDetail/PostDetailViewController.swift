//
//  PostDetailViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

enum PostDetailSectionItem {
    case post(PostModel)
    case comment([Comment])
}

// 섹션에 대한 데이터 모델
struct PostDetailSectionModel {
    let title: String?
    var items: [PostDetailSectionItem]
}

// SectionModelType 프로토콜 준수
extension PostDetailSectionModel: SectionModelType {
    typealias Item = PostDetailSectionItem
    
    init(original: PostDetailSectionModel, items: [PostDetailSectionItem]) {
        self = original
        self.items = items
    }
}

class PostDetailViewController: BaseViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = PostDetailViewModel()
    let postDetailView = PostDetailView()
    
    var postID: String = ""
    
    lazy var dataSource = configureDataSource()
    
    override func loadView() {
        self.view = postDetailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let viewDidLoadTrigger = Observable.just(postID)
        let input = PostDetailViewModel.Input(viewDidLoadTrigger: viewDidLoadTrigger)
        
        let output = viewModel.transform(input: input)
        output.postDetail.bind(with: self) { owner, value in
            let sections: [PostDetailSectionModel] = [PostDetailSectionModel(title: nil, items: [.post(value)]),
                                                      PostDetailSectionModel(title: "내 게시물", items: [.comment(value.comments)])]
                                                      
            Observable.just(sections).bind(to: owner.postDetailView.tableView.rx.items(dataSource: owner.dataSource)).disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxTableViewSectionedReloadDataSource<PostDetailSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<PostDetailSectionModel>(
            configureCell: { dataSource, tableView, indexPath, item in
                switch item {
                case .post(let post):
                    if post.files.isEmpty {
                        let cell = tableView.dequeueReusableCell(withIdentifier: PostDetailWithoutImageTableViewCell.identifier, for: indexPath) as! PostDetailWithoutImageTableViewCell
                        cell.postTitleLabel.text = post.title
                        cell.postContentLabel.text = post.content
                        cell.likeCountLabel.text = "\(post.likes.count)"
                        cell.commentCountLabel.text = "\(post.comments.count)"
                        cell.nickNameLabel.text = post.creator.nick
                        return cell
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: PostDetailTableViewCell.identifier, for: indexPath) as! PostDetailTableViewCell
                        cell.postTitleLabel.text = post.title
                        cell.postContentLabel.text = post.content
                        cell.likeCountLabel.text = "\(post.likes.count)"
                        cell.commentCountLabel.text = "\(post.comments.count)"
                        cell.nickNameLabel.text = post.creator.nick
                        return cell
                    }
                case .comment(let comment):
                    let cell = tableView.dequeueReusableCell(withIdentifier: PostDetailCommentTableViewCell.identifier, for: indexPath) as! PostDetailCommentTableViewCell
                    if indexPath.row < comment.count {
                            // 배열의 인덱스가 유효하면 해당 인덱스의 댓글을 가져와서 표시합니다.
                            cell.nicknameLabel.text = comment[indexPath.row].creator.nick
                        } else {
                            // 인덱스가 유효하지 않으면 빈 문자열을 설정합니다.
                            cell.nicknameLabel.text = ""
                        }
                    return cell
                }
            }
        )
        return dataSource
    }
}
