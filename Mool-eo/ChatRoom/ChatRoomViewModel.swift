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
        let newChat: Observable<String>
        let newChatUploadButtonTap: Observable<Void>
        let newChatImageSelectButtonTap: Observable<Void>
        let selectedImageDataSubject: BehaviorSubject<[Data]>
        let modelSelected: Observable<ChatRoomSectionItem>
        let itemSelected: Observable<IndexPath>
    }
    
    struct Output {
        let chatList: Observable<[Chat]>
        let newChat: PublishSubject<Chat>
        let newChatImageSelectButtonTap: Observable<Void>
        let isTextEmpty: BehaviorSubject<Bool>
        let chatImageTapTrigger: PublishSubject<[String]>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let roomId = PublishSubject<String>()
        let beforChatListFetchSuccessTrigger = PublishSubject<Void>()
        let chatList = PublishSubject<[Chat]>()
        let newChat = PublishSubject<Chat>()
        let isTextEmpty = BehaviorSubject<Bool>(value: true)
        let filesModelSubject = PublishSubject<FilesModel>()
        let chatImageTapTrigger = PublishSubject<[String]>()
        let networkFail = PublishSubject<Void>()
        
        // 채팅방 생성 및 과거 채팅 내역 불러오기
        produceChatRoom(input: input, roomId: roomId, networkFail: networkFail)
        fetchAndSaveChatHistory(roomId: roomId, beforChatListFetchSuccessTrigger: beforChatListFetchSuccessTrigger, chatList: chatList, networkFail: networkFail)
        updateChatListAndSetupSocket(beforChatListFetchSuccessTrigger: beforChatListFetchSuccessTrigger, roomId: roomId, chatList: chatList)
        
        checkAndUpdateTextEmptyState(input: input, isTextEmpty: isTextEmpty)
        
        // 채팅 전송 관련 로직
        sendTextChat(input: input, roomId: roomId, networkFail: networkFail)
        chatImageUpload(input: input, roomId: roomId, filesModelSubject: filesModelSubject, networkFail: networkFail)
        sendImageChat(filesModelSubject: filesModelSubject, roomId: roomId, networkFail: networkFail)

        handleReceivedChatData(newChat: newChat)
        
        handleImageChatDetail(input: input, chatImageTapTrigger: chatImageTapTrigger)
        
        return Output(chatList: chatList,
                      newChat: newChat,
                      newChatImageSelectButtonTap: input.newChatImageSelectButtonTap,
                      isTextEmpty: isTextEmpty,
                      chatImageTapTrigger: chatImageTapTrigger,
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
    
    private func produceChatRoom(input: Input, roomId: PublishSubject<String>, networkFail: PublishSubject<Void>) {
        input.userId
            .map { ChatProduceQuery(opponent_id: $0) }
            .flatMap { NetworkManager.shared.chatProduce(query: $0) }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let chatRoomModel): roomId.onNext(chatRoomModel.roomID)
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func fetchAndSaveChatHistory(roomId: PublishSubject<String>, beforChatListFetchSuccessTrigger: PublishSubject<Void>, chatList: PublishSubject<[Chat]>, networkFail: PublishSubject<Void>) {
        roomId
            .flatMap { [weak self] roomId in
                if let lastChat = self?.repository.fetchLatestChatByRoom(roomId) {
                    return NetworkManager.shared.chatHistoryCheck(roomId: roomId, cursorDate: lastChat.createdAt)
                } else {
                    return NetworkManager.shared.chatHistoryCheck(roomId: roomId, cursorDate: "")
                }
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let chatHistoryModel):
                    chatHistoryModel.data.forEach { chatModel in
                        owner.manageChatSavingToRealm(chatModel)
                    }
                    beforChatListFetchSuccessTrigger.onNext(())
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func updateChatListAndSetupSocket(beforChatListFetchSuccessTrigger: PublishSubject<Void>, roomId: PublishSubject<String>, chatList: PublishSubject<[Chat]>) {
        beforChatListFetchSuccessTrigger
            .withLatestFrom(roomId)
            .bind(with: self) { owner, roomId in
                chatList.onNext(owner.repository.fetchByRoom(roomId))
                owner.socketSetting(roomId: roomId)
            }
            .disposed(by: disposeBag)
    }
    
    private func checkAndUpdateTextEmptyState(input: Input, isTextEmpty: BehaviorSubject<Bool>) {
        input.newChat
            .map { $0.isEmpty }
            .bind(with: self) { owner, value in
                if try! isTextEmpty.value() != value {
                    isTextEmpty.onNext(value)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func sendTextChat(input: Input, roomId: PublishSubject<String>, networkFail: PublishSubject<Void>) {
        input.newChatUploadButtonTap
            .withLatestFrom(input.newChat)
            .map { ChatSendQuery(content: $0, files: nil) }
            .withLatestFrom(roomId) { query, roomId in
                return (query, roomId)
            }
            .flatMap { (query, roomId) in
                NetworkManager.shared.chatSend(query: query, roomId: roomId)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let chat): print(chat)
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func chatImageUpload(input: Input, roomId: PublishSubject<String>, filesModelSubject: PublishSubject<FilesModel>, networkFail: PublishSubject<Void>) {
        input.selectedImageDataSubject
            .map { FilesQuery(files: $0) }
            .withLatestFrom(roomId) { query, roomId in
                return (query, roomId)
            }
            .flatMap { (query, roomId) in
                NetworkManager.shared.chatImageUpload(query: query, roomId: roomId)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let filesModel): filesModelSubject.onNext(filesModel)
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func sendImageChat(filesModelSubject: PublishSubject<FilesModel>, roomId: PublishSubject<String>, networkFail: PublishSubject<Void>) {
        filesModelSubject
            .map { ChatSendQuery(content: nil, files: $0.files) }
            .withLatestFrom(roomId) { query, roomId in
                return (query, roomId)
            }
            .flatMap { (query, roomId) in
                NetworkManager.shared.chatSend(query: query, roomId: roomId)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let chat): print(chat)
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func handleReceivedChatData(newChat: PublishSubject<Chat>) {
        SocketIOManager.shared.receivedChatData
            .subscribe(with: self) { owner, chat in
                newChat.onNext(chat)
            }
            .disposed(by: disposeBag)
    }
    
    private func handleImageChatDetail(input: Input, chatImageTapTrigger: PublishSubject<[String]>) {
        Observable.zip(input.modelSelected, input.itemSelected)
            .map { $0.0 }
            .bind(with: self) { owner, value in
                switch value {
                case .chat(let chat):
                    if !chat.filesArray.isEmpty {
                        chatImageTapTrigger.onNext(chat.filesArray)
                    }
                }
            }
            .disposed(by: disposeBag)
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
    
    private func handleNetworkError(error: NetworkError, networkFail: PublishSubject<Void>) {
        switch error {
        case .networkFail: networkFail.onNext(())
        default: print("⚠️OTHER ERROR : \(error)⚠️")
        }
    }
}
