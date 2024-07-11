//
//  ImageChatViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 6/30/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ImageChatViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let filesArray: Observable<[String]>
        let changePage: Observable<Void>
    }
    
    struct Output {
        let filesArray: Observable<[String]>
        let pageCount: PublishSubject<Int>
        let changePage: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let pageCount = PublishSubject<Int>()
        
        input.filesArray
            .map { $0.count }
            .bind(with: self) { owner, count in
                pageCount.onNext(count)
            }
            .disposed(by: disposeBag)
        
        return Output(filesArray: input.filesArray,
                      pageCount: pageCount,
                      changePage: input.changePage)
    }
}
