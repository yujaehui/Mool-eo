//
//  PostDetailViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import Foundation
import RxSwift
import RxCocoa

class PostDetailViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let keyboardWillShow: Observable<Notification>
        let keyboardWillHide: Observable<Notification>
        let textViewBegin: Observable<Void>
        let textViewEnd: Observable<Void>
        let postId: Observable<String>
        let userId: String
        let reload: BehaviorSubject<Void>
        let comment: Observable<String>
        let commentUploadButtonTap: Observable<Void>
        let likeStatus: PublishSubject<Bool>
        let scrapStauts: PublishSubject<Bool>
        let postEditButtonTap: Observable<Void>
        let postDeleteButtonTap: Observable<Void>
        let itemDeletedWithCommentId: Observable<(IndexPath, String)>
    }
    
    struct Output {
        let keyboardWillShow: Observable<Notification>
        let keyboardWillHide: Observable<Notification>
        let text: Driver<String?>
        let textColorType: Driver<Bool>
        let postDetail: PublishSubject<PostModel>
        let editPostDetail: PublishSubject<PostModel>
        let accessType: Driver<postDetailAccessType>
        let commentUploadSuccessTrigger: Driver<Void>
        let likeUploadSuccessTrigger: Driver<Void>
        let scrapUploadSuccessTrigger: Driver<Void>
        let postDeleteSuccessTrigger: Driver<Void>
        let commentDeleteSuccessTrigger: Driver<IndexPath>
    }
    
    func transform(input: Input) -> Output {
        let placeholderText = "댓글을 입력해주세요"
        let text = BehaviorRelay<String?>(value: placeholderText)
        let textColorType = BehaviorRelay<Bool>(value: false)
        let postDetail = PublishSubject<PostModel>()
        let editPostDetail = PublishSubject<PostModel>()
        let accessType = PublishSubject<postDetailAccessType>()
        let commentUploadSuccessTrigger = PublishSubject<Void>()
        let likeUploadSuccessTrigger = PublishSubject<Void>()
        let scrapUploadSuccessTrigger = PublishSubject<Void>()
        let postDeleteSuccessTrigger = PublishSubject<Void>()
        let commentDeleteSuccessTrigger = PublishSubject<IndexPath>()
        
        // 텍스트뷰 입력이 시작되는 시점
        input.textViewBegin
            .withLatestFrom(input.comment)
            .bind(with: self) { owner, value in
                if value == text.value {
                    text.accept(nil)
                    textColorType.accept(true)
                }
            }.disposed(by: disposeBag)
        
        // 텍스트뷰 입력이 종료되는 시점
        input.textViewEnd
            .withLatestFrom(input.comment)
            .bind(with: self) { owner, value in
                if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    text.accept(placeholderText)
                    textColorType.accept(false)
                }
            }.disposed(by: disposeBag)
        
        // MARK: - 특정 게시글 조회 네트워크 통신 진행
        input.reload
            .withLatestFrom(input.postId)
            .flatMap { value in
                NetworkManager.shared.postCheckSpecific(postId: value)
            }
            .debug("특정 게시글 조회")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postModel):
                    // 특정 게시글 조회
                    postDetail.onNext(postModel)
                    // 자신의 게시글인지 확인
                    if postModel.creator.userID == input.userId {
                        accessType.onNext(.me)
                    } else {
                        accessType.onNext(.other)
                    }
                case .error(let error): print(error)
                }
            }.disposed(by: disposeBag)
        
        // MARK: - 댓글 업로드 네트워크 통신 진행
        let commentQuery = input.comment.map { content in
            return CommentQuery(content: content)
        }

        let commentObservable = Observable.combineLatest(commentQuery, input.postId)
        
        input.commentUploadButtonTap
            .withLatestFrom(commentObservable)
            .flatMap { commentQuery, postId in
                NetworkManager.shared.commentUpload(query: commentQuery, postId: postId)
            }.debug("댓글")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(_): commentUploadSuccessTrigger.onNext(())
                case .error(let error): print(error)
                }
            }.disposed(by: disposeBag)
        
        // MARK: - 좋아요 업로드 네트워크 통신 진행
        let likeQuery = input.likeStatus.map { status in
            return LikeQuery(like_status: status)
        }
        
        let likeObservable = Observable.combineLatest(likeQuery, input.postId)

        input.likeStatus
            .withLatestFrom(likeObservable)
            .flatMap { likeQuery, postId in
                NetworkManager.shared.likeUpload(query: likeQuery, postId: postId)
            }
            .debug("좋아요 업로드")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(_): likeUploadSuccessTrigger.onNext(())
                case .error(let error): print(error)
                }
            }.disposed(by: disposeBag)
        
        // MARK: - 스크랩 업로드 네트워크 통신 진행
        let scrapQuery = input.scrapStauts.map { status in
            return ScrapQuery(like_status: status)
        }
        
        let scrapObservable = Observable.combineLatest(scrapQuery, input.postId)
        
        input.scrapStauts
            .withLatestFrom(scrapObservable)
            .flatMap { scrapQuery, postId in
                NetworkManager.shared.scrapUpload(query: scrapQuery, postId: postId)
            }
            .debug("스크랩 업로드")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(_): scrapUploadSuccessTrigger.onNext(())
                case .error(let error): print(error)
                }
            }.disposed(by: disposeBag)
        
        //MARK: - 특정 게시물 삭제 네트워크 통신 진행
        input.postDeleteButtonTap
            .withLatestFrom(input.postId)
            .flatMap { postId in
                NetworkManager.shared.postDelete(postId: postId)
            }
            .debug("특정 게시물 삭제")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(_): postDeleteSuccessTrigger.onNext(())
                case .error(let error): print(error)
                }
            }.disposed(by: disposeBag)
        
        //MARK: - 댓글 삭제 네트워크 통신 진행
        input.itemDeletedWithCommentId
            .flatMap { indexPath, commentId in
                input.postId
                    .take(1)
                    .flatMap { postId in
                        NetworkManager.shared.commentDelete(postId: postId, commentId: commentId)
                            .map { result in (indexPath, result) }
                    }
            }
            .debug("댓글 삭제")
            .subscribe(with: self) { owner, value in
                switch value.1 {
                case .success(_): commentDeleteSuccessTrigger.onNext(value.0)
                case .error(let error): print(error)
                }
            }.disposed(by: disposeBag)
        
        input.postEditButtonTap
            .withLatestFrom(input.postId)
            .flatMap { value in
                NetworkManager.shared.postCheckSpecific(postId: value)
            }
            .debug("특정 게시글 조회")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postModel): editPostDetail.onNext(postModel)
                case .error(let error): print(error)
                }
            }.disposed(by: disposeBag)
        
        return Output(keyboardWillShow: input.keyboardWillShow,
                      keyboardWillHide: input.keyboardWillHide,
                      text: text.asDriver(),
                      textColorType: textColorType.asDriver(),
                      postDetail: postDetail,
                      editPostDetail: editPostDetail,
                      accessType: accessType.asDriver(onErrorJustReturn: .other),
                      commentUploadSuccessTrigger: commentUploadSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      likeUploadSuccessTrigger: likeUploadSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      scrapUploadSuccessTrigger: scrapUploadSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      postDeleteSuccessTrigger: postDeleteSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      commentDeleteSuccessTrigger: commentDeleteSuccessTrigger.asDriver(onErrorJustReturn: IndexPath()))
    }
}
