//
//  PostListViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import Foundation
import RxSwift
import RxCocoa

class PostListViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let viewDidLoadTrigger: Observable<PostBoardType>
        let postWriteButtonTap: Observable<Void>
        let modelSelected: Observable<PostModel>
        let itemSelected: Observable<IndexPath>
    }
    
    struct Output {
        let postList: PublishSubject<[PostModel]>
        let postWriteButtonTap: Observable<Void>
        let post: PublishSubject<String>
    }
    
    func transform(input: Input) -> Output {
        let postList = PublishSubject<[PostModel]>()
        let post = PublishSubject<String>()
        
        input.viewDidLoadTrigger.flatMap { value in
            NetworkManager.postCheck(productId: value.rawValue)
        }
        .debug()
        .subscribe(with: self) { owner, value in
            postList.onNext(value.data)
        }.disposed(by: disposeBag)
        
        
        Observable.zip(input.modelSelected, input.itemSelected)
            .map { $0.0.postID }
            .bind(with: self) { owner, value in
                post.onNext(value)
            }.disposed(by: disposeBag)
        
        
        return Output(postList: postList, postWriteButtonTap: input.postWriteButtonTap, post: post)
    }
}
