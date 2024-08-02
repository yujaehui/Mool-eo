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
import IQKeyboardManagerSwift

enum postDetailAccessType {
    case me
    case other
}

final class PostDetailViewController: BaseViewController {
    
    deinit { print("‼️PostDetailViewController Deinit‼️") }
    
    private let viewModel = PostDetailViewModel()
    private let postDetailView = PostDetailView()
    
    var accessType: postDetailAccessType = .me
    var postId: String = ""
    
    private let reload = BehaviorSubject(value: ())
    private let sections = BehaviorSubject<[PostDetailSectionModel]>(value: [])

    private let likeStatus = PublishSubject<Bool>()
    private let editButtonTap = PublishSubject<Void>()
    private let deleteButtonTap = PublishSubject<Void>()
    
    private var change = false
    
    
    override func loadView() {
        self.view = postDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(PostDetailViewController.self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if change {
            NotificationCenter.default.post(name: Notification.Name(Noti.changePost.rawValue), object: ProductIdentifier.post)
        }
    }
    
    override func setNav() {
        super.setNav()
        var items: [UIAction] {
            let edit = UIAction(title: "수정", image: UIImage(systemName: "square.and.pencil"), handler: { _ in
                self.editButtonTap.onNext(())
            })
            let delete = UIAction(title: "삭제", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { _ in
                self.deleteButtonTap.onNext(())
            })
            return [edit, delete]
        }
        let menu = UIMenu(title: "", children: items)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
        navigationItem.rightBarButtonItem?.isHidden = accessType == .me ? false : true
    }
    
    override func configureView() {
        sections
            .bind(to: postDetailView.tableView.rx.items(dataSource: configureDataSource())).disposed(by: disposeBag)
    }
    
    override func bind() {
        let input = PostDetailViewModel.Input(
            keyboardWillShow: NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification),
            keyboardWillHide: NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification),
            postId: Observable.just(postId),
            reload: reload,
            postEditButtonTap: editButtonTap,
            postDeleteButtonTap: deleteButtonTap,
            likeStatus: likeStatus,
            commentTextViewBegin: postDetailView.writeCommentView.writeTextView.rx.didBeginEditing.asObservable(),
            commentTextViewEnd: postDetailView.writeCommentView.writeTextView.rx.didEndEditing.asObservable(),
            comment: postDetailView.writeCommentView.writeTextView.rx.text.orEmpty.asObservable(),
            commentUploadButtonTap: postDetailView.writeCommentView.textUploadButton.rx.tap.asObservable(),
            itemDeletedWithCommentId: postDetailView.tableView.rx.itemDeleted.flatMap { [weak self] indexPath -> Observable<(IndexPath, String)> in
                guard let sections = try? self?.sections.value(),
                      case let .comment(comment) = sections[indexPath.section].items[indexPath.row] else { return Observable.empty() }
                return Observable.just((indexPath, comment.commentId))
            })
        
        let output = viewModel.transform(input: input)
        
        output.keyboardWillShow.bind(with: self) { owner, notification in
            owner.keyboardWillShow(notification: notification)
        }.disposed(by: disposeBag)
        
        output.keyboardWillHide.bind(with: self) { owner, notification in
            owner.keyboardWillHide(notification: notification)
        }.disposed(by: disposeBag)
        
        output.commentText.drive(postDetailView.writeCommentView.writeTextView.rx.text).disposed(by: disposeBag)
        
        output.commentTextColorType.drive(with: self) { owner, value in
            owner.postDetailView.writeCommentView.writeTextView.textColor = value ? ColorStyle.mainText : ColorStyle.placeholder
        }.disposed(by: disposeBag)
        
        output.postDetail.bind(with: self) { owner, value in
            owner.sections.onNext([PostDetailSectionModel(title: nil, items: [.post(value)])]
                                  + [PostDetailSectionModel(title: "댓글", items: value.comments.map { .comment($0) })])
        }.disposed(by: disposeBag)
        
        output.commentButtonValidation.drive(postDetailView.writeCommentView.textUploadButton.rx.isEnabled).disposed(by: disposeBag)
        
        output.commentUploadSuccessTrigger.drive(with: self) { owner, _ in
            owner.postDetailView.writeCommentView.writeTextView.text = ""
            owner.change = true
            owner.reload.onNext(())
        }.disposed(by: disposeBag)
        
        output.likeUploadSuccessTrigger.drive(with: self) { owner, _ in
            owner.change = true
            owner.reload.onNext(())
        }.disposed(by: disposeBag)
        
        output.postDeleteSuccessTrigger.drive(with: self) { owner, _ in
            owner.change = true
            owner.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        output.commentDeleteSuccessTrigger.drive(with: self) { owner, indexPath in
            owner.change = true
            
            guard var sections = try? owner.sections.value() else { return }
            var items = sections[indexPath.section].items
            items.remove(at: indexPath.row)
            sections[indexPath.section] = PostDetailSectionModel(original: sections[indexPath.section], items: items)
            owner.sections.onNext(sections)
            
            owner.reload.onNext(())
            
            ToastManager.shared.showToast(title: "댓글이 삭제되었습니다", in: owner.postDetailView)
        }.disposed(by: disposeBag)
        
        output.editPostDetail.bind(with: self) { owner, value in
            let vc = WritePostViewController()
            vc.type = .edit
            vc.postTitle = value.title
            vc.postContent = value.content
            vc.postFiles = value.files
            vc.postId = value.postId
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            owner.present(nav, animated: true)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.postDetailView)
        }.disposed(by: disposeBag)
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
                            if post.creator.userId != UserDefaultsManager.userId {
                                let vc = OtherUserProfileViewController()
                                vc.nickname = post.creator.nick
                                vc.userId = post.creator.userId
                                owner.navigationController?.pushViewController(vc, animated: true)
                            } else {
                                let vc = UserProfileViewController()
                                owner.navigationController?.pushViewController(vc, animated: true)
                            }
                        }.disposed(by: cell.disposeBag)
                    cell.likeButton.rx.tap.bind(with: self) { owner, _ in
                        let userId = UserDefaultsManager.userId!
                        let status = !post.likePost.contains(userId)
                        owner.likeStatus.onNext(status)
                    }.disposed(by: cell.disposeBag)
                    return cell
                } else { // 이미지가 있는 게시글일 경우
                    let cell = tableView.dequeueReusableCell(withIdentifier: PostDetailTableViewCell.identifier, for: indexPath) as! PostDetailTableViewCell
                    cell.configureCell(post: post)
                    cell.profileStackView.rx.tapGesture()
                        .when(.recognized)
                        .bind(with: self) { owner, value in
                            if post.creator.userId != UserDefaultsManager.userId {
                                let vc = OtherUserProfileViewController()
                                vc.nickname = post.creator.nick
                                vc.userId = post.creator.userId
                                owner.navigationController?.pushViewController(vc, animated: true)
                            } else {
                                let vc = UserProfileViewController()
                                owner.navigationController?.pushViewController(vc, animated: true)
                            }
                        }.disposed(by: cell.disposeBag)
                    cell.likeButton.rx.tap.bind(with: self) { owner, _ in
                        let userId = UserDefaultsManager.userId!
                        let status = !post.likePost.contains(userId)
                        owner.likeStatus.onNext(status)
                    }.disposed(by: cell.disposeBag)
                    return cell
                }
            case .comment(let comment): // 댓글
                let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as! CommentTableViewCell
                cell.configureCell(comment: comment)
                cell.profileStackView.rx.tapGesture()
                    .when(.recognized)
                    .bind(with: self) { owner, value in
                        if comment.creator.userId != UserDefaultsManager.userId {
                            let vc = OtherUserProfileViewController()
                            vc.nickname = comment.creator.nick
                            vc.userId = comment.creator.userId
                            owner.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            let vc = UserProfileViewController()
                            owner.navigationController?.pushViewController(vc, animated: true)
                        }
                    }.disposed(by: cell.disposeBag)
                return cell
            }
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource.sectionModels[index].title
        }, canEditRowAtIndexPath: { dataSource, indexPath in
            guard case .comment(let comment) = dataSource[indexPath],
                  comment.creator.userId == UserDefaultsManager.userId else { return false }
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
    
    private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.postDetailView.tableView.snp.updateConstraints { make in
                make.top.horizontalEdges.equalTo(self.postDetailView.safeAreaLayoutGuide)
                make.bottom.equalTo(self.postDetailView.writeCommentView.snp.top).offset(-10)
            }
            
            self.postDetailView.writeCommentView.snp.updateConstraints { make in
                make.horizontalEdges.equalTo(self.postDetailView.safeAreaLayoutGuide)
                make.bottom.equalToSuperview().inset(keyboardHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.postDetailView.tableView.snp.updateConstraints { make in
                make.top.horizontalEdges.equalTo(self.postDetailView.safeAreaLayoutGuide)
                make.bottom.equalTo(self.postDetailView.writeCommentView.snp.top).offset(-10)
            }
            
            self.postDetailView.writeCommentView.snp.updateConstraints { make in
                make.horizontalEdges.equalTo(self.postDetailView.safeAreaLayoutGuide)
                make.bottom.equalToSuperview().inset(10)
            }
            self.view.layoutIfNeeded()
        }
    }
}
