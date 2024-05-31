//
//  ChattingViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ChatRoomViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    let repository = ChatRepository()
    
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
            .debug("채팅 발송")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let chatModel):
                    print(chatModel)
                    let sender = Sender(user_id: chatModel.sender.userID, nick: chatModel.sender.nick, profileImage: chatModel.sender.profileImage)
                    let data = Chat(chat_id: chatModel.chatID, room_id: chatModel.roomID, content: chatModel.content, createdAt: chatModel.createdAt, sender: sender, filesArray: chatModel.files)
                    owner.repository.createChat(data)
                case .error(let error):
                    print(error)
                }
            }.disposed(by: disposeBag)
        
        return Output(chatProduceSuccessTrigger: chatProduceSuccessTrigger)
    }
}
