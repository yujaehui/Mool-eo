//
//  PostBoardViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import Foundation
import RxSwift
import RxCocoa

class PostBoardViewModel: ViewModelType {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let postBoardList: Observable<[PostBoardType]>
        let modelSelected: Observable<PostBoardType>
        let itemSelected: Observable<IndexPath>
    }
    
    struct Output {
        let postBoardList: Observable<[PostBoardType]>
        let postBoard: Driver<PostBoardType>
    }
    
    func transform(input: Input) -> Output {
        let postBoard = PublishSubject<PostBoardType>()
        
        Observable.zip(input.modelSelected, input.itemSelected)
            .map { $0.0 }
            .bind(with: self) { owner, value in
                postBoard.onNext(value)
            }.disposed(by: disposeBag)
        
        
        return Output(postBoardList: input.postBoardList, postBoard: postBoard.asDriver(onErrorJustReturn: .free))
    }
}
