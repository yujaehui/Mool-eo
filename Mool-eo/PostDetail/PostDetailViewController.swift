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
    case comment(Comment)
}

struct PostDetailSectionModel {
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
    
    let viewModel = PostDetailViewModel()
    let postDetailView = PostDetailView()
    
    var postId: String = ""
    
    var reload = BehaviorSubject(value: ()) // 댓글이 달릴 때마다 특정 포스트 조회를 해줘야 하기 때문에
    
    override func loadView() {
        self.view = postDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let keyboardWillShow = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
        let keyboardWillHide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
        let textViewBegin = postDetailView.writeCommentView.commentTextView.rx.didBeginEditing.asObservable() // 텍스트뷰 입력이 시작하는 시점
        let textViewEnd = postDetailView.writeCommentView.commentTextView.rx.didEndEditing.asObservable() // 텍스트뷰 입력이 끝나는 시점
        let postId = Observable.just(postId)
        let comment = postDetailView.writeCommentView.commentTextView.rx.text.orEmpty.asObservable()
        let commentUploadButtonTap = postDetailView.writeCommentView.commentUploadButton.rx.tap.asObservable()
        let input = PostDetailViewModel.Input(keyboardWillShow: keyboardWillShow, keyboardWillHide: keyboardWillHide, textViewBegin: textViewBegin, textViewEnd: textViewEnd, postId: postId, comment: comment, commentUploadButtonTap: commentUploadButtonTap, reload: reload)
        
        let output = viewModel.transform(input: input)
        output.postDetail.bind(with: self) { owner, value in
            let sections: [PostDetailSectionModel] = [PostDetailSectionModel(items: [.post(value)])]
            + value.comments.map { comment in
                PostDetailSectionModel(items: [.comment(comment)])
            }
            Observable.just(sections).bind(to: owner.postDetailView.tableView.rx.items(dataSource: owner.configureDataSource())).disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
        
        output.keyboardWillShow.bind(with: self) { owner, notification in
            owner.keyboardWillShow(notification: notification)
        }.disposed(by: disposeBag)
        
        output.keyboardWillHide.bind(with: self) { owner, notification in
            owner.keyboardWillHide(notification: notification)
        }.disposed(by: disposeBag)
        
        // 텍스트뷰 placeholder 작업
        output.text.drive(postDetailView.writeCommentView.commentTextView.rx.text).disposed(by: disposeBag)
        output.textColorType.drive(with: self) { owner, value in
            owner.postDetailView.writeCommentView.commentTextView.textColor = value ? ColorStyle.mainText : ColorStyle.placeholder
        }.disposed(by: disposeBag)
        
        // 댓글 업로드가 성공할 경우
        output.commentUploadSuccessTrigger.drive(with: self) { owner, _ in
            owner.postDetailView.tableView.dataSource = nil // 기존 테이블뷰 데이터소스 초기화
            owner.reload.onNext(()) // 새롭게 특정 게시글 조회 네트워크 통신 진행 (시점 전달)
        }.disposed(by: disposeBag)
    }
    
    // 키보드가 나타났을 경우 tableView와 writeCommentView의 위치 조정
    private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) {
            self.postDetailView.tableView.snp.updateConstraints { make in
                make.bottom.equalTo(self.postDetailView.writeCommentView.snp.top).offset(-10)
            }
            self.postDetailView.writeCommentView.snp.updateConstraints { make in
                make.bottom.equalTo(self.postDetailView).inset(keyboardHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // 키보드가 사라졌을 경우 tableView와 writeCommentView의 위치 조정 (초기 위치와 동일하게 설정)
    private func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.postDetailView.tableView.snp.updateConstraints { make in
                make.bottom.equalTo(self.postDetailView.writeCommentView.snp.top).offset(-10)
            }
            self.postDetailView.writeCommentView.snp.updateConstraints { make in
                make.bottom.equalTo(self.postDetailView).inset(30)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func configureDataSource() -> RxTableViewSectionedReloadDataSource<PostDetailSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<PostDetailSectionModel> { dataSource, tableView, indexPath, item in
            switch item {
            case .post(let post): // 게시글
                if post.files.isEmpty { // 이미지가 없는 게시글일 경우
                    let cell = tableView.dequeueReusableCell(withIdentifier: PostDetailWithoutImageTableViewCell.identifier, for: indexPath) as! PostDetailWithoutImageTableViewCell
                    cell.configureCell(post: post)
                    return cell
                } else { // 이미지가 있는 게시글일 경우
                    let cell = tableView.dequeueReusableCell(withIdentifier: PostDetailTableViewCell.identifier, for: indexPath) as! PostDetailTableViewCell
                    cell.configureCell(post: post)
                    return cell
                }
            case .comment(let comment): // 댓글
                let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as! CommentTableViewCell
                cell.configureCell(comment: comment)
                return cell
            }
        }
        return dataSource
    }
}
