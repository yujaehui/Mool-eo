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

enum postDetailAccessType {
    case me
    case other
}

class PostDetailViewController: BaseViewController {
    
    let viewModel = PostDetailViewModel()
    let postDetailView = PostDetailView()
    
    var postId: String = ""
    var userId: String = ""
    
    var reload = BehaviorSubject(value: ())
    var likeStatus = PublishSubject<Bool>()
    var scrapStatus = PublishSubject<Bool>()
    
    private var sections = BehaviorSubject<[PostDetailSectionModel]>(value: [])
    
    override func loadView() {
        self.view = postDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setNav() {
        navigationItem.rightBarButtonItem = postDetailView.postDeleteButton
    }
    
    override func bind() {
        sections.bind(to: postDetailView.tableView.rx.items(dataSource: configureDataSource())).disposed(by: disposeBag)
        
        let input = PostDetailViewModel.Input(
            keyboardWillShow: NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification),
            keyboardWillHide: NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification),
            textViewBegin: postDetailView.writeCommentView.commentTextView.rx.didBeginEditing.asObservable(),
            textViewEnd: postDetailView.writeCommentView.commentTextView.rx.didEndEditing.asObservable(),
            postId: Observable.just(postId),
            userId: userId,
            reload: reload,
            comment: postDetailView.writeCommentView.commentTextView.rx.text.orEmpty.asObservable(),
            commentUploadButtonTap: postDetailView.writeCommentView.commentUploadButton.rx.tap.asObservable(),
            likeStatus: likeStatus,
            scrapStauts: scrapStatus,
            postDeleteButtonTap: postDetailView.postDeleteButton.rx.tap.asObservable(),
            itemDeletedWithCommentId: postDetailView.tableView.rx.itemDeleted.flatMap { [weak self] indexPath -> Observable<(IndexPath, String)> in
                guard let sections = try? self?.sections.value(),
                      case let .comment(comment) = sections[indexPath.section].items[indexPath.row] else { return Observable.empty() }
                return Observable.just((indexPath, comment.commentID))
            })
        
        let output = viewModel.transform(input: input)
        
        // 키보드가 나타나는 경우
        output.keyboardWillShow.bind(with: self) { owner, notification in
            owner.keyboardWillShow(notification: notification)
        }.disposed(by: disposeBag)
        
        // 키보드가 사라지는 경우
        output.keyboardWillHide.bind(with: self) { owner, notification in
            owner.keyboardWillHide(notification: notification)
        }.disposed(by: disposeBag)
        
        // 텍스트뷰 placeholder 작업
        output.text.drive(postDetailView.writeCommentView.commentTextView.rx.text).disposed(by: disposeBag)
        output.textColorType.drive(with: self) { owner, value in
            owner.postDetailView.writeCommentView.commentTextView.textColor = value ? ColorStyle.mainText : ColorStyle.placeholder
        }.disposed(by: disposeBag)
        
        // 특정 게시글 조회가 성공할 경우
        output.postDetail.bind(with: self) { owner, value in
            owner.sections.onNext([PostDetailSectionModel(items: [.post(value)])] + value.comments.map { comment in
                PostDetailSectionModel(items: [.comment(comment)])
            })
        }.disposed(by: disposeBag)
        
        // 자신의 게시물인지 확인
        output.accessType.drive(with: self) { owner, value in
            switch value {
            case .me: owner.navigationItem.rightBarButtonItem?.isHidden = false
            case .other: owner.navigationItem.rightBarButtonItem?.isHidden = true
            }
        }.disposed(by: disposeBag)
        
        // 댓글 업로드가 성공할 경우
        output.commentUploadSuccessTrigger.drive(with: self) { owner, _ in
            owner.postDetailView.tableView.reloadData()
            owner.reload.onNext(()) // 새롭게 특정 게시글 조회 네트워크 통신 진행 (시점 전달)
        }.disposed(by: disposeBag)
        
        // 좋아요 업로드가 성공할 경우
        output.likeUploadSuccessTrigger.drive(with: self) { owner, _ in
            owner.postDetailView.tableView.reloadData()
            owner.reload.onNext(()) // 새롭게 특정 게시글 조회 네트워크 통신 진행 (시점 전달)
        }.disposed(by: disposeBag)
        
        // 스크랩 업로드가 성공할 경우
        output.scrapUploadSuccessTrigger.drive(with: self) { owner, _ in
            print("스크랩 성공")
        }.disposed(by: disposeBag)
        
        // 자신의 게시물 -> 삭제
        output.postDeleteSuccessTrigger.drive(with: self) { owner, _ in
            owner.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        // 댓글 삭제가 성공할 경우
        output.commentDeleteSuccessTrigger.drive(with: self) { owner, indexPath in
            guard var sections = try? owner.sections.value() else { return }
            var items = sections[indexPath.section].items
            items.remove(at: indexPath.row)
            sections[indexPath.section] = PostDetailSectionModel(original: sections[indexPath.section], items: items)
            owner.sections.onNext(sections)
            owner.postDetailView.tableView.reloadData()
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
    
    private func configureDataSource() -> RxTableViewSectionedReloadDataSource<PostDetailSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<PostDetailSectionModel> (configureCell : { dataSource, tableView, indexPath, item in
            switch item {
            case .post(let post): // 게시글
                if post.files.isEmpty { // 이미지가 없는 게시글일 경우
                    let cell = tableView.dequeueReusableCell(withIdentifier: PostDetailWithoutImageTableViewCell.identifier, for: indexPath) as! PostDetailWithoutImageTableViewCell
                    cell.configureCell(post: post)
                    cell.likeButton.rx.tap.bind(with: self) { owner, _ in
                        let userId = UserDefaults.standard.string(forKey: "userId")!
                        let status = !post.likes.contains(userId)
                        owner.likeStatus.onNext(status)
                    }.disposed(by: cell.disposeBag)
                    cell.scrapButton.rx.tap.bind(with: self) { owner, _ in
                        let userId = UserDefaults.standard.string(forKey: "userId")!
                        let status = !post.scraps.contains(userId)
                        owner.scrapStatus.onNext(status)
                    }.disposed(by: cell.disposeBag)
                    return cell
                } else { // 이미지가 있는 게시글일 경우
                    let cell = tableView.dequeueReusableCell(withIdentifier: PostDetailTableViewCell.identifier, for: indexPath) as! PostDetailTableViewCell
                    cell.configureCell(post: post)
                    cell.likeButton.rx.tap.bind(with: self) { owner, _ in
                        let userId = UserDefaults.standard.string(forKey: "userId")!
                        let status = !post.likes.contains(userId)
                        owner.likeStatus.onNext(status)
                    }.disposed(by: cell.disposeBag)
                    cell.scrapButton.rx.tap.bind(with: self) { owner, _ in
                        let userId = UserDefaults.standard.string(forKey: "userId")!
                        let status = !post.scraps.contains(userId)
                        owner.scrapStatus.onNext(status)
                    }.disposed(by: cell.disposeBag)
                    return cell
                }
            case .comment(let comment): // 댓글
                let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as! CommentTableViewCell
                cell.configureCell(comment: comment)
                return cell
            }
        },canEditRowAtIndexPath: { dataSource, indexPath in
            guard case .comment(let comment) = dataSource[indexPath],
                  comment.creator.userID == UserDefaults.standard.string(forKey: "userId") else { return false }
            return true
        })
        return dataSource
    }
}
