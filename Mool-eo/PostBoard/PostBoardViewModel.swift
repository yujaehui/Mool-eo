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
    }
    
    struct Output {
        let postBoardList: Observable<[PostBoardType]>
    }
    
    func transform(input: Input) -> Output {
        return Output(postBoardList: input.postBoardList)
    }
}
