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

        }.disposed(by: disposeBag)
        
        output.newChatListSubject.bind(with: self) { owner, value in
            owner.sections
                .take(1)
                .subscribe(onNext: { currentSections in
                    var updatedSections = currentSections
                    let updatedItems = updatedSections[0].items + value.map { .chat($0) }
                    updatedSections[0] = ChatRoomSectionModel(items: updatedItems)
                    owner.sections.onNext(updatedSections)
                    
                    let lastSection = owner.chatRoomView.tableView.numberOfSections - 1
                    let lastRow = owner.chatRoomView.tableView.numberOfRows(inSection: lastSection) - 1
                    let lastIndexPath = IndexPath(row: lastRow, section: lastSection)
                    owner.chatRoomView.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
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
                    cell.chatLabel.text = chat.content
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: OtherChatTableViewCell.identifier, for: indexPath) as! OtherChatTableViewCell
                    cell.chatLabel.text = chat.content
                    return cell
                }
            }
        })
        return dataSource
    }
}
