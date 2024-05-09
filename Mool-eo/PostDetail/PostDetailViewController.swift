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
import RxGesture
import Toast

enum postDetailAccessType {
    case me
    case other
}

class PostDetailViewController: BaseViewController {
    
    deinit {
        print("‼️PostDetailViewController Deinit‼️")
    }
    
    let viewModel = PostDetailViewModel()
    let postDetailView = PostDetailView()
    
    var postBoard: PostBoardType = .free
    var postId: String = ""
    var userId: String = ""
    
    var reload = BehaviorSubject(value: ())
    var likeStatus = PublishSubject<Bool>()
    var scrapStatus = PublishSubject<Bool>()
    var editButtonTap = PublishSubject<Void>()
    var deleteButtonTap = PublishSubject<Void>()
    var change = false
    
    private var sections = BehaviorSubject<[PostDetailSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    
    override func loadView() {
        self.view = postDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if change {
            NotificationCenter.default.post(name: Notification.Name(Noti.changePost.rawValue), object: postBoard)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true) // 화면 터치시 키보드 내려가도록
    }
    
    override func setNav() {
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = ColorStyle.point
        var items: [UIAction] {
            let edit = UIAction(title: "수정", image: UIImage(systemName: "square.and.pencil"), handler: { _ in
                self.editButtonTap.onNext(())
            })
            let delete = UIAction(title: "삭제", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { _ in
                self.deleteButtonTap.onNext(())
            })
            let Items = [edit, delete]
            return Items
        }
        let menu = UIMenu(title: "", children: items)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
    }
    
    override func bind() {
        sections.bind(to: postDetailView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        let input = PostDetailViewModel.Input(
            didScroll: postDetailView.tableView.rx.didScroll.asObservable(),
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
            postEditButtonTap: editButtonTap,
            postDeleteButtonTap: deleteButtonTap,
            itemDeletedWithCommentId: postDetailView.tableView.rx.itemDeleted.flatMap { [weak self] indexPath -> Observable<(IndexPath, String)> in
                guard let sections = try? self?.sections.value(),
                      case let .comment(comment) = sections[indexPath.section].items[indexPath.row] else { return Observable.empty() }
                return Observable.just((indexPath, comment.commentID))
            })
        
        let output = viewModel.transform(input: input)
        
        output.didScroll.bind(with: self) { owner, _ in
            owner.view.endEditing(true)
        }.disposed(by: disposeBag)
        
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
            owner.sections.onNext([PostDetailSectionModel(title: nil, items: [.post(value)])]
                                  + [PostDetailSectionModel(title: "댓글", items: value.comments.map { .comment($0) })])
        }.disposed(by: disposeBag)
        
        // 자신의 게시물인지 확인
        output.accessType.drive(with: self) { owner, value in
            switch value {
            case .me: owner.navigationItem.rightBarButtonItem?.isHidden = false
            case .other: owner.navigationItem.rightBarButtonItem?.isHidden = true
            }
        }.disposed(by: disposeBag)
        
        output.commentButtonValidation.drive(postDetailView.writeCommentView.commentUploadButton.rx.isEnabled).disposed(by: disposeBag)
        
        // 댓글 업로드가 성공할 경우
        output.commentUploadSuccessTrigger.drive(with: self) { owner, _ in
            owner.postDetailView.writeCommentView.commentTextView.text = ""
            owner.change = true
            owner.reload.onNext(()) // 새롭게 특정 게시글 조회 네트워크 통신 진행 (시점 전달)
        }.disposed(by: disposeBag)
        
        // 좋아요 업로드가 성공할 경우
        output.likeUploadSuccessTrigger.drive(with: self) { owner, _ in
            owner.change = true
            owner.reload.onNext(()) // 새롭게 특정 게시글 조회 네트워크 통신 진행 (시점 전달)
        }.disposed(by: disposeBag)
        
        // 스크랩 업로드가 성공할 경우
        output.scrapUploadSuccessTrigger.drive(with: self) { owner, _ in
            owner.change = true
            owner.reload.onNext(()) // 새롭게 특정 게시글 조회 네트워크 통신 진행 (시점 전달)
        }.disposed(by: disposeBag)
        
        // 자신의 게시물 -> 삭제
        output.postDeleteSuccessTrigger.drive(with: self) { owner, _ in
            owner.change = true
            owner.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        // 댓글 삭제가 성공할 경우
        output.commentDeleteSuccessTrigger.drive(with: self) { owner, indexPath in
            owner.change = true
            
            guard var sections = try? owner.sections.value() else { return }
            var items = sections[indexPath.section].items
            items.remove(at: indexPath.row)
            sections[indexPath.section] = PostDetailSectionModel(original: sections[indexPath.section], items: items)
            owner.sections.onNext(sections)
            
            owner.reload.onNext(()) // 새롭게 특정 게시글 조회 네트워크 통신 진행 (시점 전달)
            
            ToastManager.shared.showToast(title: "댓글이 삭제되었습니다", in: owner.postDetailView)
        }.disposed(by: disposeBag)
        
        output.editPostDetail.bind(with: self) { owner, value in
            let vc = WritePostViewController()
            vc.type = .edit
            vc.postBoard = owner.postBoard
            vc.postTitle = value.title
            vc.postContent = value.content
            vc.postFiles = value.files
            vc.postId = value.postID
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            owner.present(nav, animated: true)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.postDetailView)
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
                    cell.profileStackView.rx.tapGesture()
                        .when(.recognized)
                        .bind(with: self) { owner, value in
                            if post.creator.userID != UserDefaultsManager.userId {
                                let vc = OtherUserProfileViewController()
                                vc.userId = post.creator.userID
                                owner.navigationController?.pushViewController(vc, animated: true)
                            } else {
                                let vc = ProfileViewController()
                                owner.navigationController?.pushViewController(vc, animated: true)
                            }
                        }.disposed(by: cell.disposeBag)
                    cell.likeButton.rx.tap.bind(with: self) { owner, _ in
                        let userId = UserDefaultsManager.userId!
                        let status = !post.likes.contains(userId)
                        owner.likeStatus.onNext(status)
                    }.disposed(by: cell.disposeBag)
                    cell.scrapButton.rx.tap.bind(with: self) { owner, _ in
                        let userId = UserDefaultsManager.userId!
                        let status = !post.scraps.contains(userId)
                        owner.scrapStatus.onNext(status)
                    }.disposed(by: cell.disposeBag)
                    return cell
                } else { // 이미지가 있는 게시글일 경우
                    let cell = tableView.dequeueReusableCell(withIdentifier: PostDetailTableViewCell.identifier, for: indexPath) as! PostDetailTableViewCell
                    cell.configureCell(post: post)
                    cell.profileStackView.rx.tapGesture()
                        .when(.recognized)
                        .bind(with: self) { owner, value in
                            if post.creator.userID != UserDefaultsManager.userId {
                                let vc = OtherUserProfileViewController()
                                vc.userId = post.creator.userID
                                owner.navigationController?.pushViewController(vc, animated: true)
                            } else {
                                let vc = ProfileViewController()
                                owner.navigationController?.pushViewController(vc, animated: true)
                            }
                        }.disposed(by: cell.disposeBag)
                    cell.likeButton.rx.tap.bind(with: self) { owner, _ in
                        let userId = UserDefaultsManager.userId!
                        let status = !post.likes.contains(userId)
                        owner.likeStatus.onNext(status)
                    }.disposed(by: cell.disposeBag)
                    cell.scrapButton.rx.tap.bind(with: self) { owner, _ in
                        let userId = UserDefaultsManager.userId!
                        let status = !post.scraps.contains(userId)
                        owner.scrapStatus.onNext(status)
                    }.disposed(by: cell.disposeBag)
                    return cell
                }
            case .comment(let comment): // 댓글
                let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as! CommentTableViewCell
                cell.configureCell(comment: comment)
                cell.profileStackView.rx.tapGesture()
                    .when(.recognized)
                    .bind(with: self) { owner, value in
                        if comment.creator.userID != UserDefaultsManager.userId {
                            let vc = OtherUserProfileViewController()
                            vc.userId = comment.creator.userID
                            owner.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            let vc = ProfileViewController()
                            owner.navigationController?.pushViewController(vc, animated: true)
                        }
                    }.disposed(by: cell.disposeBag)
                return cell
            }
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource.sectionModels[index].title
        }, canEditRowAtIndexPath: { dataSource, indexPath in
            guard case .comment(let comment) = dataSource[indexPath],
                  comment.creator.userID == UserDefaultsManager.userId else { return false }
            return true
        })
        return dataSource
    }
    
    private func registerObserver() {
        NotificationCenter.default.rx.notification(Notification.Name(Noti.writePost.rawValue))
            .take(until: self.rx.deallocated)
            .subscribe(with: self) { owner, _ in
                owner.reload.onNext(())
            }
            .disposed(by: disposeBag)
    }
    
}
