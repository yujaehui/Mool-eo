//
//  ChattingViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import Foundation
import RxSwift
import RxCocoa

class ChatRoomViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let userId: Observable<String>
        let roomId: Observable<String>
        let newChat: Observable<String>
        let newChatUploadButtonTap: Observable<Void>
    }
    
    struct Output {
        let chatProduceSuccessTrigger: PublishSubject<ChatRoomModel>
    }
    
    func transform(input: Input) -> Output {
        let chatProduceSuccessTrigger = PublishSubject<ChatRoomModel>()
        
        input.userId
            .map { userId in
                return ChatProduceQuery(opponent_id: userId)
            }
            .flatMap { query in
                NetworkManager.shared.chatProduce(query: query)
            }
            .debug("채팅방 생성")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let success): chatProduceSuccessTrigger.onNext(success)
                case .error(let error): print(error)
                }
            }.disposed(by: disposeBag)
        
        let chatSendQuery = Observable.combineLatest(input.newChat, input.newChatUploadButtonTap)
            .map { value in
                return ChatSendQuery(content: value.0, files: nil)
            }
        
        chatSendQuery
            .withLatestFrom(input.roomId) { query, roomId in
                return (query, roomId)
            }
            .flatMap { (query, roomId) in
                NetworkManager.shared.chatSend(query: query, roomId: roomId)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let chatModel):
                    print(chatModel)
                case .error(let error):
                    print(error)
                }
            }.disposed(by: disposeBag)
        
        return Output(chatProduceSuccessTrigger: chatProduceSuccessTrigger)
    }
}
