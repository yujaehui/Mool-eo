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
    let socketManager = SocketIOManager.shared
    
    struct Input {
        let userId: Observable<String>
        let roomId: Observable<String>
        let newChat: Observable<String>
        let newChatUploadButtonTap: Observable<Void>
        let newChatImageSelectButtonTap: Observable<Void>
        let selectedImageDataSubject: BehaviorSubject<[Data]>
    }
    
    struct Output {
        let chatRoom: PublishSubject<ChatRoomModel>
        let chatList: Observable<[Chat]>
        let newChat: PublishSubject<Chat>
        let newChatImageSelectButtonTap: Observable<Void>
        let isTextEmpty: BehaviorSubject<Bool>
    }
    
    func transform(input: Input) -> Output {
        let chatRoom = PublishSubject<ChatRoomModel>()
        let beforChatListFetchSuccessTrigger = PublishSubject<Void>()
        let chatList = PublishSubject<[Chat]>()
        let newChat = PublishSubject<Chat>()
        let isTextEmpty = BehaviorSubject<Bool>(value: true)
        let filesModelSubject = PublishSubject<FilesModel>()

        
        input.userId
            .map { userId in
                return ChatProduceQuery(opponent_id: userId)
            }
            .flatMap { query in
                NetworkManager.shared.chatProduce(query: query)
            }
            .debug("채팅 생성")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let chatRoomModel):
                    chatRoom.onNext(chatRoomModel)
                case .error(let error):
                    print(error)
                }
            }.disposed(by: disposeBag)
        
        input.roomId
            .flatMap { [weak self] roomId in
                if let lastChat = self?.repository.fetchLatestChatByRoom(roomId) {
                    NetworkManager.shared.chatHistoryCheck(roomId: roomId, cursorDate: lastChat.createdAt)
                } else {
                    NetworkManager.shared.chatHistoryCheck(roomId: roomId, cursorDate: "")
                }
            }
            .debug("채팅 조회")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let chatHistoryModel):
                    chatHistoryModel.data.forEach { chatModel in
                        self.manageChatSavingToRealm(chatModel)
                    }
                    beforChatListFetchSuccessTrigger.onNext(())
                case .error(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        
        beforChatListFetchSuccessTrigger
            .withLatestFrom(input.roomId)
            .bind(with: self) { owner, roomId in
                chatList.onNext(owner.repository.fetchByRoom(roomId))
                owner.socketSetting(roomId: roomId)
            }.disposed(by: disposeBag)
        
        input.newChatUploadButtonTap
            .withLatestFrom(input.newChat)
            .map { content in
                return ChatSendQuery(content: content, files: nil)
            }
            .withLatestFrom(input.roomId) { query, roomId in
                return (query, roomId)
            }
            .flatMap { (query, roomId) in
                NetworkManager.shared.chatSend(query: query, roomId: roomId)
            }
            .debug("채팅 발송")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let chat): print(chat)
                case .error(let error): print(error)
                }
            }.disposed(by: disposeBag)
        
        input.selectedImageDataSubject
            .map { files in
                return FilesQuery(files: files)
            }
            .withLatestFrom(input.roomId, resultSelector: { query, roomId in
                return (query, roomId)
            })
            .flatMap { (query, roomId) in
                NetworkManager.shared.chatImageUpload(query: query, roomId: roomId)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let filesModel):
                    filesModelSubject.onNext(filesModel)
                case .error(let error): print(error)
                }
            }.disposed(by: disposeBag)
        
        filesModelSubject
            .map { filesModel in
                return ChatSendQuery(content: nil, files: filesModel.files)
            }
            .withLatestFrom(input.roomId) { query, roomId in
                return (query, roomId)
            }
            .flatMap { (query, roomId) in
                NetworkManager.shared.chatSend(query: query, roomId: roomId)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let chat): print(chat)
                case .error(let error): print(error)
                }
            }.disposed(by: disposeBag)
        
        SocketIOManager.shared.receivedChatData
            .subscribe(with: self) { owner, chat in
                newChat.onNext(chat)
            }.disposed(by: disposeBag)
        
        input.newChat
            .map { $0.isEmpty }
            .bind(with: self) { onwer, value in
                if try! isTextEmpty.value() != value {
                    isTextEmpty.onNext(value)
                }
            }.disposed(by: disposeBag)
        
        return Output(chatRoom: chatRoom, chatList: chatList, newChat: newChat, newChatImageSelectButtonTap: input.newChatImageSelectButtonTap, isTextEmpty: isTextEmpty)
    }
    
    private func manageChatSavingToRealm(_ chat: Chat) {
        if let chatSender = chat.sender {
            let sender = Sender(user_id: chatSender.user_id, nick: chatSender.nick, profileImage: chatSender.profileImage)
            let data = Chat(chat_id: chat.chat_id, room_id: chat.room_id, content: chat.content, createdAt: chat.createdAt, sender: sender, filesArray: chat.filesArray)
            repository.createChat(data)
        }
    }
    
    private func socketSetting(roomId: String) {
        socketManager.roomId = roomId
        socketManager.initializeSocket()
        socketManager.establishConnection()
    }
}
