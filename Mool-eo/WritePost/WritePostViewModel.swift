//
//  WritePostViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import Foundation
import RxSwift
import RxCocoa

class WritePostViewModel: ViewModelType {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let textViewBegin: Observable<Void>
        let textViewEnd: Observable<Void>
        let postBoard: PostBoardType
        let title: Observable<String>
        let content: Observable<String>
        let selectedImageDataSubject: PublishSubject<[Data]>
        let imageSelectedSubject: BehaviorSubject<Bool>
        let imageAddButtonTap: Observable<Void>
        let completeButtonTap: Observable<Void>
        let cancelButtonTap: Observable<Void>
        let type: PostInteractionType
        let postId: Observable<String>
    }
    
    struct Output {
        let text: Driver<String?>
        let textColorType: Driver<Bool>
        let imageAddButtonTap: Driver<Void>
        let uploadSuccessTrigger: Driver<Void>
        let editSuccessTrigger: Driver<Void>
        let cancelButtonTap: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let placeholderText = "내용을 입력해주세요"
        let text = PublishRelay<String?>()
        let textColorType = PublishRelay<Bool>()
        let uploadSuccessTrigger = PublishSubject<Void>()
        let editSuccessTrigger = PublishSubject<Void>()
        
        input.textViewBegin
            .withLatestFrom(input.content)
            .debug("텍스트뷰 시작")
            .bind(with: self) { owner, value in
                if value == placeholderText {
                    text.accept(nil)
                    textColorType.accept(true)
                }
            }.disposed(by: disposeBag)
        
        input.textViewEnd
            .withLatestFrom(input.content)
            .debug("텍스트뷰 종료")
            .bind(with: self) { owner, value in
                if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    text.accept(placeholderText)
                    textColorType.accept(false)
                }
            }.disposed(by: disposeBag)
        
        
        let filesQuery = input.selectedImageDataSubject.map { files in
            return FilesQuery(files: files)
        }
        
        let postQuery = Observable.combineLatest(input.title, input.content).map { (title, content) in
            return PostQuery(title: title, content: content, product_id: input.postBoard.rawValue, files: nil)
        }
        
        let editPostObservable = Observable.combineLatest(postQuery, input.postId)
        
        switch input.type {
        case .upload:
            input.completeButtonTap
                .withLatestFrom(input.imageSelectedSubject)
                .map { imageSelected -> Observable<PostQuery> in
                    if imageSelected {
                        return filesQuery
                            .flatMap { filesQuery in
                                NetworkManager.shared.imageUpload(query: filesQuery)
                            }
                            .withLatestFrom(postQuery) { filesModel, postObservable in
                                (filesModel, postObservable)
                            }
                            .map { filesModel, postObservable in
                                PostQuery(title: postObservable.title, content: postObservable.content, product_id: input.postBoard.rawValue, files: filesModel.files)
                            }
                    } else {
                        return postQuery
                    }
                }
                .flatMap { query in
                    query
                }
                .flatMap { query in
                    NetworkManager.shared.postUpload(query: query)
                }
                .debug("게시글 업로드")
                .subscribe(with: self) { owner, _ in
                    uploadSuccessTrigger.onNext(())
                } onError: { owner, error in
                    print("오류 발생")
                }.disposed(by: disposeBag)
        case .edit:
            input.completeButtonTap
                .withLatestFrom(editPostObservable)
                .flatMap { query, postId in
                    NetworkManager.shared.postEdit(query: query, postId: postId)
                }
                .debug("게시글 수정")
                .subscribe(with: self) { owner, value in
                    editSuccessTrigger.onNext(())
                } onError: { owner, error in
                    print("오류 발생")
                }.disposed(by: disposeBag)
        }
    
        return Output(text: text.asDriver(onErrorJustReturn: ""),
                      textColorType: textColorType.asDriver(onErrorJustReturn: false),
                      imageAddButtonTap: input.imageAddButtonTap.asDriver(onErrorJustReturn: ()),
                      uploadSuccessTrigger: uploadSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      editSuccessTrigger: editSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      cancelButtonTap: input.cancelButtonTap.asDriver(onErrorJustReturn: ()))
    }
}
