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
        let postBoard: ProductIdentifier
        let title: Observable<String>
        let content: Observable<String>
        let selectedImageDataSubject: BehaviorSubject<[Data]>
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
        let completeButtonValidation: Driver<Bool>
        let uploadSuccessTrigger: Driver<Void>
        let editSuccessTrigger: Driver<Void>
        let badRequest: Driver<Void>
        let notFoundErr: Driver<Void>
        let networkFail: Driver<Void>
        let cancelButtonTap: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let placeholderText = "내용을 입력해주세요"
        let text = PublishRelay<String?>()
        let textColorType = PublishRelay<Bool>()
        let completeButtonValidation = BehaviorSubject(value: false)
        let uploadSuccessTrigger = PublishSubject<Void>()
        let editSuccessTrigger = PublishSubject<Void>()
        let badRequest = PublishSubject<Void>()
        let notFoundErr = PublishSubject<Void>()
        let networkFail = PublishSubject<Void>()
        
        input.textViewBegin
            .withLatestFrom(input.content)
            .bind(with: self) { owner, value in
                if value == placeholderText {
                    text.accept(nil)
                    textColorType.accept(true)
                }
            }.disposed(by: disposeBag)
        
        input.textViewEnd
            .withLatestFrom(input.content)
            .bind(with: self) { owner, value in
                if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    text.accept(placeholderText)
                    textColorType.accept(false)
                }
            }.disposed(by: disposeBag)
        
        Observable.combineLatest(input.title, input.content)
            .map { (title, content) in
                return title != "" && content != "" && content != placeholderText
            }
            .bind(with: self) { owner, value in
                completeButtonValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        
        let filesQuery = input.selectedImageDataSubject.map { files in
            return FilesQuery(files: files)
        }
        
        let postQuery = Observable.combineLatest(input.title, input.content).map { (title, content) in
            return PostQuery(title: title, content: content, content1: nil, product_id: input.postBoard.rawValue, files: nil)
        }
        
        let editPostObservable = Observable.combineLatest(postQuery, input.postId)
        
        switch input.type {
        case .upload:
            input.completeButtonTap
                .withLatestFrom(input.imageSelectedSubject)
                .flatMap { imageSelected -> Observable<PostQuery> in
                    if imageSelected {
                        return filesQuery
                            .flatMapLatest { filesQuery in
                                NetworkManager.shared.imageUpload(query: filesQuery)
                            }
                            .flatMapLatest { result -> Observable<PostQuery> in
                                switch result {
                                case .success(let filesModel):
                                    return Observable.combineLatest(input.title, input.content).map { (title, content) in
                                        return PostQuery(title: title, content: content, content1: nil, product_id: input.postBoard.rawValue, files: filesModel.files)
                                    }
                                case .error(let error):
                                    switch error {
                                    case .badRequest: badRequest.onNext(())
                                    case .networkFail: networkFail.onNext(())
                                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                                    }
                                    return Observable.combineLatest(input.title, input.content).map { (title, content) in
                                        return PostQuery(title: title, content: content, content1: nil, product_id: input.postBoard.rawValue, files: nil)
                                    }
                                }
                            }
                    } else {
                        let postQuery = Observable.combineLatest(input.title, input.content).map { (title, content) in
                            return PostQuery(title: title, content: content, content1: nil, product_id: input.postBoard.rawValue, files: nil)
                        }
                        return postQuery
                    }
                }
                .flatMap { query in
                    NetworkManager.shared.postUpload(query: query)
                }
                .debug("게시글 업로드")
                .subscribe(with: self) { owner, value in
                    switch value {
                    case .success(_): uploadSuccessTrigger.onNext(())
                    case .error(let error):
                        switch error {
                        case .notFoundErr: notFoundErr.onNext(())
                        case .networkFail: networkFail.onNext(())
                        default: print("⚠️OTHER ERROR : \(error)⚠️")
                        }
                    }
                }.disposed(by: disposeBag)
            
        case .edit:
            input.completeButtonTap
                .withLatestFrom(editPostObservable)
                .flatMap { query, postId in
                    NetworkManager.shared.postEdit(query: query, postId: postId)
                }
                .debug("게시글 수정")
                .subscribe(with: self) { owner, value in
                    switch value {
                    case .success(_): editSuccessTrigger.onNext(())
                    case .error(let error):
                        switch error {
                        case .networkFail: networkFail.onNext(())
                        default: print("⚠️OTHER ERROR : \(error)⚠️")
                        }
                    }
                }.disposed(by: disposeBag)
        }
        
        return Output(text: text.asDriver(onErrorJustReturn: ""),
                      textColorType: textColorType.asDriver(onErrorJustReturn: false),
                      imageAddButtonTap: input.imageAddButtonTap.asDriver(onErrorJustReturn: ()),
                      completeButtonValidation: completeButtonValidation.asDriver(onErrorJustReturn: false),
                      uploadSuccessTrigger: uploadSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      editSuccessTrigger: editSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      badRequest: badRequest.asDriver(onErrorJustReturn: ()),
                      notFoundErr: notFoundErr.asDriver(onErrorJustReturn: ()),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()),
                      cancelButtonTap: input.cancelButtonTap.asDriver(onErrorJustReturn: ()))
    }
}
