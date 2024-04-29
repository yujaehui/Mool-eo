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
        let postBoardType: Observable<PostBoardType>
        let postWriteButtonTap: Observable<Void>
        let modelSelected: Observable<PostModel>
        let itemSelected: Observable<IndexPath>
    }
    
    struct Output {
        let postList: PublishSubject<[PostModel]>
        let postWriteButtonTap: Driver<Void>
        let post: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let postList = PublishSubject<[PostModel]>()
        let post = PublishSubject<String>()
        
        // 게시글 조회 네트워크 통신 진행
        input.postBoardType.flatMap { value in
            NetworkManager.postCheck(productId: value.rawValue)
        }
        .debug("게시글 조회")
        .subscribe(with: self) { owner, value in
            postList.onNext(value.data)
        } onError: { owner, error in
            print("오류 발생")
        }.disposed(by: disposeBag)
        
        Observable.zip(input.modelSelected, input.itemSelected)
            .map { $0.0.postID }
            .bind(with: self) { owner, value in
                post.onNext(value)
            }.disposed(by: disposeBag)
        
        return Output(postList: postList,
                      postWriteButtonTap: input.postWriteButtonTap.asDriver(onErrorJustReturn: ()),
                      post: post.asDriver(onErrorJustReturn: ""))
    }
}
