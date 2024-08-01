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
import PhotosUI
import YPImagePicker

final class ChatRoomViewController: BaseViewController {
    
    deinit {
        SocketIOManager.shared.leaveConnection()
        print("‼️ChatRoomViewController Deinit‼️")
    }
    
    let viewModel = ChatRoomViewModel()
    let chatRoomView = ChatRoomView()
    
    private var reload = BehaviorSubject<Void>(value: ())
    private var sections = BehaviorSubject<[ChatRoomSectionModel]>(value: [])
    
    private var selectedImageData: [Data] = []
    private var selectedImageDataSubject = BehaviorSubject<[Data]>(value: [])
    
    private var lastSender: Sender?
    
    var userId: String = ""
    var nickname: String = ""
    
    override func loadView() {
        self.view = chatRoomView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setNav() {
        super.setNav()
        navigationItem.title = nickname
    }
    
    override func configureView() {
        sections.bind(to: chatRoomView.tableView.rx.items(dataSource: configureDataSource())).disposed(by: disposeBag)
    }
    
    override func bind() {
        let intput = ChatRoomViewModel.Input(
            userId: Observable.just(userId),
            newChat: chatRoomView.writeMessageView.writeTextView.rx.text.orEmpty.asObservable(),
            newChatUploadButtonTap: chatRoomView.writeMessageView.textUploadButton.rx.tap.asObservable(),
            newChatImageSelectButtonTap: chatRoomView.writeMessageView.imageSelectButton.rx.tap.asObservable(),
            selectedImageDataSubject: selectedImageDataSubject,
            modelSelected: chatRoomView.tableView.rx.modelSelected(ChatRoomSectionItem.self).asObservable(),
            itemSelected: chatRoomView.tableView.rx.itemSelected.asObservable()
        )
        
        let output = viewModel.transform(input: intput)
        
        output.chatList.bind(with: self) { owner, value in
            owner.configureSection(value)
        }.disposed(by: disposeBag)
        
        output.newChat.bind(with: self) { owner, value in
            owner.updateSection(value)
            owner.chatRoomView.writeMessageView.writeTextView.text = ""
            NotificationCenter.default.post(name: Notification.Name(Noti.newChat.rawValue), object: nil)
        }.disposed(by: disposeBag)
        
        output.newChatImageSelectButtonTap.bind(with: self) { owner, _ in
            owner.presentPHPicker(delegate: owner, selectionLimit: 5)
        }.disposed(by: disposeBag)
        
        output.isTextEmpty.bind(with: self) { owner, isTextEmpty in
            owner.chatRoomView.writeMessageView.updateButtonVisibility(isTextEmpty: isTextEmpty)
        }.disposed(by: disposeBag)
        
        output.chatImageTapTrigger.bind(with: self) { owner, filesArray in
            owner.navigateToImageChat(filesArray)
        }.disposed(by: disposeBag)
    }
}

extension ChatRoomViewController {
    private func configureDataSource() -> RxTableViewSectionedReloadDataSource<ChatRoomSectionModel> {
        return RxTableViewSectionedReloadDataSource<ChatRoomSectionModel>(
            configureCell: { dataSource, tableView, indexPath, item in
                if indexPath.row == 0 {
                    return self.configureHeaderCell(dataSource, tableView: tableView, indexPath: indexPath)
                } else {
                    return self.configureChatCell(dataSource, tableView: tableView, indexPath: indexPath, item: item)
                }
            }
        )
    }
    
    private func configureHeaderCell(_ dataSource: TableViewSectionedDataSource<ChatRoomSectionModel>, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatDateTableViewCell.identifier, for: indexPath) as! ChatDateTableViewCell
        cell.configureCell(dataSource.sectionModels[indexPath.section].date)
        return cell
    }
    
    private func configureChatCell(_ dataSource: TableViewSectionedDataSource<ChatRoomSectionModel>, tableView: UITableView, indexPath: IndexPath, item: ChatRoomSectionItem) -> UITableViewCell {
        switch item {
        case .chat(let chat):
            return chat.sender?.user_id == UserDefaultsManager.userId
            ? self.configureMyChatCell(chat, tableView: tableView, indexPath: indexPath)
            : self.configureOtherChatCell(chat, tableView: tableView, indexPath: indexPath)
        }
    }
    
    private func configureMyChatCell(_ chat: Chat, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let isLastInSequence = checkIfLastInSequence(for: chat, at: indexPath, in: tableView)
        if chat.filesArray.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: MyChatTableViewCell.identifier, for: indexPath) as! MyChatTableViewCell
            cell.configureCell(chat, showTime: isLastInSequence)
            return cell
        } else {
            return self.configureMyImageChatCell(chat, tableView: tableView, indexPath: indexPath)
        }
    }
    
    private func configureOtherChatCell(_ chat: Chat, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let isLastInSequence = checkIfLastInSequence(for: chat, at: indexPath, in: tableView)
        if chat.filesArray.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: OtherChatTableViewCell.identifier, for: indexPath) as! OtherChatTableViewCell
            cell.configureCell(chat, lastSender: lastSender, showTime: isLastInSequence)
            return cell
        } else {
            return self.configureOtherImageChatCell(chat, tableView: tableView, indexPath: indexPath)
        }
    }
    
    private func checkIfLastInSequence(for chat: Chat, at indexPath: IndexPath, in tableView: UITableView) -> Bool {
        let sectionItems = try? sections.value()[indexPath.section].items
        guard let items = sectionItems else { return true }
        
        if indexPath.row == items.count - 1 {
            return true
        } else {
            if case let .chat(nextChat) = items[indexPath.row + 1] {
                return DateFormatterManager.shared.formatTimeToString(timeString: chat.createdAt) != DateFormatterManager.shared.formatTimeToString(timeString: nextChat.createdAt)
            }
            return true
        }
    }
    
    private func configureMyImageChatCell(_ chat: Chat, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let isLastInSequence = checkIfLastInSequence(for: chat, at: indexPath, in: tableView)
        switch chat.filesArray.count {
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: MyTwoImageChatTableViewCell.identifier, for: indexPath) as! MyTwoImageChatTableViewCell
            cell.configureCell(chat, showTime: isLastInSequence)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: MyThreeImageChatTableViewCell.identifier, for: indexPath) as! MyThreeImageChatTableViewCell
            cell.configureCell(chat, showTime: isLastInSequence)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: MyImageChatTableViewCell.identifier, for: indexPath) as! MyImageChatTableViewCell
            cell.configureCell(chat, showTime: isLastInSequence)
            return cell
        }
    }
    
    private func configureOtherImageChatCell(_ chat: Chat, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let isLastInSequence = checkIfLastInSequence(for: chat, at: indexPath, in: tableView)
        switch chat.filesArray.count {
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: OtherTwoImageChatTableViewCell.identifier, for: indexPath) as! OtherTwoImageChatTableViewCell
            cell.configureCell(chat, lastSender: lastSender, showTime: isLastInSequence)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: OtherThreeImageChatTableViewCell.identifier, for: indexPath) as! OtherThreeImageChatTableViewCell
            cell.configureCell(chat, lastSender: lastSender, showTime: isLastInSequence)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: OtherImageChatTableViewCell.identifier, for: indexPath) as! OtherImageChatTableViewCell
            cell.configureCell(chat, lastSender: lastSender, showTime: isLastInSequence)
            return cell
        }
    }
}

extension ChatRoomViewController {
    private func configureSection(_ value: [Chat]) {
        if let lastChat = value.last(where: { $0.sender?.user_id != UserDefaultsManager.userId }), let sender = lastChat.sender {
            lastSender = sender
        }
        
        let groupedChats = Dictionary(grouping: value) { (chat) -> String in
            return DateFormatterManager.shared.formatDateToString(dateString: chat.createdAt)
        }
        
        let sortedKeys = groupedChats.keys.sorted()
        var sections: [ChatRoomSectionModel] = []
        
        for key in sortedKeys {
            if let chats = groupedChats[key] {
                var items: [ChatRoomSectionItem] = [.chat(Chat(chat_id: "", room_id: "", content: "", createdAt: "", sender: Sender(user_id: "", nick: "", profileImage: ""), filesArray: []))]
                items.append(contentsOf: chats.map { .chat($0) })
                sections.append(ChatRoomSectionModel(date: key, items: items))
            }
        }
        
        self.sections.onNext(sections)
        
        guard value.isEmpty else { return scrollToBottom(animated: false) }
    }
    
    private func updateSection(_ value: Chat) {
        sections
            .take(1)
            .subscribe(with: self) { owner, currentSections in
                var updatedSections = currentSections
                let chatDate = DateFormatterManager.shared.formatDateToString(dateString: value.createdAt)
                
                if let index = updatedSections.firstIndex(where: { $0.date == chatDate }) {
                    var items = updatedSections[index].items
                    items.append(.chat(value))
                    updatedSections[index] = ChatRoomSectionModel(original: updatedSections[index], items: items)
                } else {
                    var items: [ChatRoomSectionItem] = [.chat(Chat(chat_id: "", room_id: "", content: "", createdAt: "", sender: Sender(user_id: "", nick: "", profileImage: ""), filesArray: []))]
                    items.append(.chat(value))
                    updatedSections.append(ChatRoomSectionModel(date: chatDate, items: items))
                    updatedSections.sort { $0.date < $1.date }
                }
                
                owner.sections.onNext(updatedSections)
                owner.scrollToBottom(animated: true)
            }
            .disposed(by: disposeBag)
        chatRoomView.writeMessageView.writeTextView.text = ""
    }
    
    private func scrollToBottom(animated: Bool) {
        let lastSection = chatRoomView.tableView.numberOfSections - 1
        let lastRow = chatRoomView.tableView.numberOfRows(inSection: lastSection) - 1
        let lastIndexPath = IndexPath(row: lastRow, section: lastSection)
        chatRoomView.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: animated)
    }
}

extension ChatRoomViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // 기존 선택 초기화
            self.selectedImageData.removeAll()
            
            let group = DispatchGroup()
            
            for result in results {
                group.enter()
                let itemProvider = result.itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        defer { group.leave() }
                        
                        guard let self = self, let image = image as? UIImage else { return }
                        
                        autoreleasepool {
                            if let downsampledImage = image.downsample(to: .screenWidth),
                               let downsampleImageData = downsampledImage.pngData() {
                                self.selectedImageData.append(downsampleImageData)
                            }
                        }
                    }
                } else {
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.selectedImageDataSubject.onNext(self.selectedImageData)
                picker.dismiss(animated: true)
            }
        }
    }
}

extension ChatRoomViewController {
    private func navigateToImageChat(_ filesArray: [String]) {
        let vc = ImageChatViewController()
        vc.filesArray = filesArray
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
