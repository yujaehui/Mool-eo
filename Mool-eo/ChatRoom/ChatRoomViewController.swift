//
//  ChatRoomViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ChatRoomViewController: BaseViewController {
    
    deinit {
        SocketIOManager.shared.leaveConnection()
        print("‼️ChatRoomViewController Deinit‼️")
    }
    
    let viewModel = ChatRoomViewModel()
    let chatRoomView = ChatRoomView()
    private var sections = BehaviorSubject<[ChatRoomSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    
    var reload = BehaviorSubject<Void>(value: ())
    var userId: String = ""
    var roomId = PublishSubject<String>()
    
    override func loadView() {
        self.view = chatRoomView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setNav() {
        
    }
    
    override func configureView() {
        sections.bind(to: chatRoomView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    override func bind() {
        let userId = Observable.just(userId)
        let roomId = roomId
        let newChat = chatRoomView.wirteTextView.wirteTextView.rx.text.orEmpty.asObservable()
        let newChatUploadButtonTap = chatRoomView.wirteTextView.textUploadButton.rx.tap.asObservable()
        let intput = ChatRoomViewModel.Input(userId: userId, roomId: roomId, newChat: newChat, newChatUploadButtonTap: newChatUploadButtonTap)
        
        let output = viewModel.transform(input: intput)
        output.chatRoom.bind(with: self) { owner, value in
            owner.roomId.onNext(value.roomID)
        }.disposed(by: disposeBag)
        
        output.chatList.bind(with: self) { owner, value in
            owner.sections.onNext([ChatRoomSectionModel(items: value.map { .chat($0) })])
            owner.scrollToBottom(animated: false)
        }.disposed(by: disposeBag)
        
        output.newChat.bind(with: self) { owner, value in
            owner.sections
                .take(1)
                .subscribe(onNext: { currentSections in
                    var updatedSections = currentSections
                    if updatedSections.isEmpty {
                        updatedSections.append(ChatRoomSectionModel(items: [.chat(value)]))
                    } else {
                        var items = updatedSections[0].items
                        items.append(.chat(value))
                        updatedSections[0] = ChatRoomSectionModel(items: items)
                    }
                    owner.sections.onNext(updatedSections)
                    owner.scrollToBottom(animated: true)
                })
                .disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
    }
    
    private func configureDataSource() -> RxTableViewSectionedReloadDataSource<ChatRoomSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<ChatRoomSectionModel> (configureCell : { dataSource, tableView, indexPath, item in
            switch item {
            case .chat(let chat):
                if chat.sender?.user_id == UserDefaultsManager.userId {
                    let cell = tableView.dequeueReusableCell(withIdentifier: MyChatTableViewCell.identifier, for: indexPath) as! MyChatTableViewCell
                    cell.configureCell(chat)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: OtherChatTableViewCell.identifier, for: indexPath) as! OtherChatTableViewCell
                    cell.configureCell(chat)
                    return cell
                }
            }
        })
        return dataSource
    }
    
    private func scrollToBottom(animated: Bool) {
        let lastSection = chatRoomView.tableView.numberOfSections - 1
        let lastRow = chatRoomView.tableView.numberOfRows(inSection: lastSection) - 1
        let lastIndexPath = IndexPath(row: lastRow, section: lastSection)
        chatRoomView.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: animated)
    }
}
