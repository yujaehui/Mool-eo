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
        let imageSelected: Bool
        let imageAddButtonTap: Observable<Void>
        let completeButtonTap: Observable<Void>
        let cancelButtonTap: Observable<Void>
    }
    
    struct Output {
        let text: Driver<String?>
        let textColorType: Driver<Bool>
        let imageAddButtonTap: Driver<Void>
        let uploadSuccessTrigger: Driver<Void>
        let cancelButtonTap: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let placeholderText = "내용을 입력해주세요"
        let text = BehaviorRelay<String?>(value: placeholderText)
        let textColorType = BehaviorRelay<Bool>(value: false)
        let uploadSuccessTrigger = PublishSubject<Void>()
        
        input.textViewBegin
            .withLatestFrom(input.content)
            .bind(with: self) { owner, value in
                if value == text.value {
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
        
        
        let filesQuery = input.selectedImageDataSubject.map { files in
            return FilesQuery(files: files)
        }
        
        let postQuery = Observable.combineLatest(input.title, input.content).map { (title, content) in
            return PostQuery(title: title, content: content, product_id: input.postBoard.rawValue, files: nil)
        }
        
        // 게시글 업로드 네트워크 통신 진행
        if input.imageSelected {
            input.completeButtonTap
                .withLatestFrom(filesQuery)
                .flatMap { filesQuery in
                    NetworkManager.shared.imageUpload(query: filesQuery)
                }
                .withLatestFrom(postQuery) { filesModel, postObservable in
                    (filesModel, postObservable)
                }
                .map { filesModel, postObservable in
                    PostQuery(title: postObservable.title, content: postObservable.content, product_id: input.postBoard.rawValue, files: filesModel.files)
                }
                .flatMap { postQuery in
                    NetworkManager.shared.postUpload(query: postQuery)
                }
                .debug("게시글 업로드")
                .subscribe(with: self) { owner, _ in
                    uploadSuccessTrigger.onNext(())
                } onError: { owner, error in
                    print("오류 발생")
                }.disposed(by: disposeBag)
        } else {
            input.completeButtonTap
                .withLatestFrom(postQuery)
                .flatMap { postQuery in
                    NetworkManager.shared.postUpload(query: postQuery)
                }
                .debug("게시글 업로드")
                .subscribe(with: self) { owner, _ in
                    uploadSuccessTrigger.onNext(())
                } onError: { owner, error in
                    print("오류 발생")
                }.disposed(by: disposeBag)
        }
        
        return Output(text: text.asDriver(),
                      textColorType: textColorType.asDriver(),
                      imageAddButtonTap: input.imageAddButtonTap.asDriver(onErrorJustReturn: ()),
                      uploadSuccessTrigger: uploadSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      cancelButtonTap: input.cancelButtonTap.asDriver(onErrorJustReturn: ()))
    }
}
