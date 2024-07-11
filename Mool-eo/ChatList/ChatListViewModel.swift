//
//  ChatListViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ChatListViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<Void>
        let modelSelected: Observable<ChatRoomModel>
        let itemSelected: Observable<IndexPath>
    }
    
    struct Output {
        let chatList: PublishSubject<[ChatRoomModel]>
        let selectedChatRoom: PublishSubject<ChatRoomModel>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let chatList = PublishSubject<[ChatRoomModel]>()
        let selectedChatRoom = PublishSubject<ChatRoomModel>()
        let networkFail = PublishSubject<Void>()
        
        input.reload
            .flatMap { NetworkManager.shared.chatListCheck() }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let chatListModel): chatList.onNext(chatListModel.data)
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
        
        Observable.zip(input.modelSelected, input.itemSelected)
            .map { $0.0 }
            .bind(with: self) { owner, value in
                selectedChatRoom.onNext(value)
            }
            .disposed(by: disposeBag)
        
        return Output(chatList: chatList,
                      selectedChatRoom: selectedChatRoom,
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
    
    private func handleNetworkError(error: NetworkError, networkFail: PublishSubject<Void>) {
        switch error {
        case .networkFail: networkFail.onNext(())
        default: print("⚠️OTHER ERROR : \(error)⚠️")
        }
    }
}
