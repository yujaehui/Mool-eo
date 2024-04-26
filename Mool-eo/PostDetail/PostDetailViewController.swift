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

struct PostDetailSectionModel {
    let title: String?
    var items: [PostDetailSectionItem]
}

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
        let keyboardWillShow = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
        let keyboardWillHide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
        let comment = postDetailView.commentTextView.textView.rx.text.orEmpty.asObservable()
        let textViewBegin = postDetailView.commentTextView.textView.rx.didBeginEditing.asObservable()
        let textViewEnd = postDetailView.commentTextView.textView.rx.didEndEditing.asObservable()
        let viewDidLoadTrigger = Observable.just(postID)
        let input = PostDetailViewModel.Input(keyboardWillShow: keyboardWillShow, keyboardWillHide: keyboardWillHide, comment: comment, textViewBegin: textViewBegin, textViewEnd: textViewEnd, viewDidLoadTrigger: viewDidLoadTrigger)
        
        let output = viewModel.transform(input: input)
        output.postDetail.bind(with: self) { owner, value in
            let sections: [PostDetailSectionModel] = [PostDetailSectionModel(title: nil, items: [.post(value)]),
                                                      PostDetailSectionModel(title: nil, items: [.comment(value.comments)])]
            
            Observable.just(sections).bind(to: owner.postDetailView.tableView.rx.items(dataSource: owner.dataSource)).disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
        
        output.keyboardWillShow.bind(with: self) { owner, notification in
            owner.keyboardWillShow(notification: notification)
        }.disposed(by: disposeBag)
        
        output.keyboardWillHide.bind(with: self) { owner, notification in
            owner.keyboardWillHide(notification: notification)
        }.disposed(by: disposeBag)
        
        output.text.drive(postDetailView.commentTextView.textView.rx.text).disposed(by: disposeBag)
        output.textColorType.drive(with: self) { owner, value in
            owner.postDetailView.commentTextView.textView.textColor = value ? ColorStyle.mainText : ColorStyle.placeholder
        }.disposed(by: disposeBag)
    }
    
    private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) {
            self.postDetailView.tableView.snp.updateConstraints { make in
                make.bottom.equalTo(self.postDetailView.commentTextView.snp.top).offset(-10)
            }
            self.postDetailView.commentTextView.snp.updateConstraints { make in
                make.bottom.equalTo(self.postDetailView).inset(keyboardHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.postDetailView.tableView.snp.updateConstraints { make in
                make.bottom.equalTo(self.postDetailView.commentTextView.snp.top).offset(-10)
            }
            self.postDetailView.commentTextView.snp.updateConstraints { make in
                make.bottom.equalTo(self.postDetailView).inset(30)
            }
            self.view.layoutIfNeeded()
        }
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
                    if comment.isEmpty {
                        let cell = tableView.dequeueReusableCell(withIdentifier: PostDetailNoCommentTableViewCell.identifier, for: indexPath) as! PostDetailNoCommentTableViewCell
                        return cell
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: PostDetailCommentTableViewCell.identifier, for: indexPath) as! PostDetailCommentTableViewCell
                        return cell
                    }
                }
            }
        )
        return dataSource
    }
}
