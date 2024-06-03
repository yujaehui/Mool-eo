//
//  WriteProductPostViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import Foundation
import RxSwift
import RxCocoa

class WriteProductPostViewModel: ViewModelType {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let textViewBegin: Observable<Void>
        let textViewEnd: Observable<Void>
        let selectedImageDataSubject: BehaviorSubject<[Data]>
        let category: Observable<String>
        let productName: Observable<String>
        let price: Observable<String>
        let detail: Observable<String>
        let imageAddButtonTap: Observable<Void>
        let completeButtonTap: Observable<Void>
        let cancelButtonTap: Observable<Void>
    }
    
    struct Output {
        let text: Driver<String?>
        let textColorType: Driver<Bool>
        let imageAddButtonTap: Driver<Void>
        let completeButtonValidation: Driver<Bool>
        let uploadSuccessTrigger: Driver<Void>
        let badRequest: Driver<Void>
        let notFoundErr: Driver<Void>
        let networkFail: Driver<Void>
        let cancelButtonTap: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let placeholderText = "내용을 입력해주세요"
        let text = BehaviorRelay<String?>(value: placeholderText)
        let textColorType = BehaviorRelay<Bool>(value: false)
        let completeButtonValidation = BehaviorSubject(value: false)
        let uploadSuccessTrigger = PublishSubject<Void>()
        let badRequest = PublishSubject<Void>()
        let notFoundErr = PublishSubject<Void>()
        let networkFail = PublishSubject<Void>()
        
        input.textViewBegin
            .withLatestFrom(input.detail)
            .bind(with: self) { owner, value in
                if value == placeholderText {
                    text.accept(nil)
                    textColorType.accept(true)
                }
            }.disposed(by: disposeBag)
        
        input.textViewEnd
            .withLatestFrom(input.detail)
            .bind(with: self) { owner, value in
                if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    text.accept(placeholderText)
                    textColorType.accept(false)
                }
            }.disposed(by: disposeBag)
        
        Observable.combineLatest(input.category, input.productName, input.price, input.detail, input.selectedImageDataSubject)
            .map { (category, productName, price, detail, imageData) in
                return !productName.isEmpty && !price.isEmpty && !detail.isEmpty && !imageData.isEmpty && detail != placeholderText && category != "카테고리를 선택해주세요"
            }
            .bind(with: self) { owner, value in
                completeButtonValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        let filesQuery = input.selectedImageDataSubject.map { files in
            return FilesQuery(files: files)
        }
        
        input.completeButtonTap
            .withLatestFrom(filesQuery)
            .flatMap { query in
                NetworkManager.shared.imageUpload(query: query)
            }
            .flatMapLatest { result -> Observable<PostQuery> in
                switch result {
                case .success(let filesModel):
                    return Observable.combineLatest(input.category, input.productName, input.price, input.detail).map { (category ,productName, price, detail) in
                        return PostQuery(title: productName,
                                         content: detail + HashtagManager.shared.convertToHashtagsAndUnderscore(category),
                                         content1: price,
                                         product_id: ProductIdentifier.market.rawValue,
                                         files: filesModel.files)
                    }
                case .error(let error):
                    switch error {
                    case .badRequest: badRequest.onNext(())
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                    return Observable.combineLatest(input.productName, input.price, input.detail).map { (productName, price, detail) in
                        return PostQuery(title: productName, content: detail, content1: price, product_id: ProductIdentifier.market.rawValue, files: nil)
                    }
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
        
        
        return Output(text: text.asDriver(onErrorJustReturn: ""),
                      textColorType: textColorType.asDriver(onErrorJustReturn: false),
                      imageAddButtonTap: input.imageAddButtonTap.asDriver(onErrorJustReturn: ()),
                      completeButtonValidation: completeButtonValidation.asDriver(onErrorJustReturn: false),
                      uploadSuccessTrigger: uploadSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      badRequest: badRequest.asDriver(onErrorJustReturn: ()),
                      notFoundErr: notFoundErr.asDriver(onErrorJustReturn: ()),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()),
                      cancelButtonTap: input.cancelButtonTap.asDriver(onErrorJustReturn: ()))
    }
}
