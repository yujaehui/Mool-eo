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
        }.disposed(by: disposeBag)
        
        output.newChatImageSelectButtonTap.bind(with: self) { owner, _ in
            owner.presentImagePicker()
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
        return RxTableViewSectionedReloadDataSource<ChatRoomSectionModel> { dataSource, tableView, indexPath, item in
            return self.configureCell(dataSource, tableView: tableView, indexPath: indexPath, item: item)
        }
    }
    
    private func configureCell(_ dataSource: TableViewSectionedDataSource<ChatRoomSectionModel>, tableView: UITableView, indexPath: IndexPath, item: ChatRoomSectionItem) -> UITableViewCell {
        switch item {
        case .chat(let chat):
            return chat.sender?.user_id == UserDefaultsManager.userId
                ? self.configureMyChatCell(chat, tableView: tableView, indexPath: indexPath)
                : self.configureOtherChatCell(chat, tableView: tableView, indexPath: indexPath)
        }
    }
    
    private func configureMyChatCell(_ chat: Chat, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if chat.filesArray.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: MyChatTableViewCell.identifier, for: indexPath) as! MyChatTableViewCell
            cell.configureCell(chat)
            return cell
        } else {
            return self.configureMyImageChatCell(chat, tableView: tableView, indexPath: indexPath)
        }
    }
    
    private func configureOtherChatCell(_ chat: Chat, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if chat.filesArray.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: OtherChatTableViewCell.identifier, for: indexPath) as! OtherChatTableViewCell
            cell.configureCell(chat)
            return cell
        } else {
            return self.configureOtherImageChatCell(chat, tableView: tableView, indexPath: indexPath)
        }
    }
    
    private func configureMyImageChatCell(_ chat: Chat, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch chat.filesArray.count {
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: MyTwoImageChatTableViewCell.identifier, for: indexPath) as! MyTwoImageChatTableViewCell
            cell.configureCell(chat)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: MyThreeImageChatTableViewCell.identifier, for: indexPath) as! MyThreeImageChatTableViewCell
            cell.configureCell(chat)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: MyImageChatTableViewCell.identifier, for: indexPath) as! MyImageChatTableViewCell
            cell.configureCell(chat)
            return cell
        }
    }
    
    private func configureOtherImageChatCell(_ chat: Chat, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch chat.filesArray.count {
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: OtherTwoImageChatTableViewCell.identifier, for: indexPath) as! OtherTwoImageChatTableViewCell
            cell.configureCell(chat)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: OtherThreeImageChatTableViewCell.identifier, for: indexPath) as! OtherThreeImageChatTableViewCell
            cell.configureCell(chat)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: OtherImageChatTableViewCell.identifier, for: indexPath) as! OtherImageChatTableViewCell
            cell.configureCell(chat)
            return cell
        }
    }
}

extension ChatRoomViewController {
    private func configureSection(_ value: [Chat]) {
        sections.onNext([ChatRoomSectionModel(items: value.map { .chat($0) })])
        guard value.isEmpty else { return scrollToBottom(animated: false) }
    }
    
    private func updateSection(_ value: Chat) {
        sections
            .take(1)
            .subscribe(with: self) { owner, currentSections in
                var updatedSections = currentSections
                if updatedSections.isEmpty {
                    updatedSections.append(ChatRoomSectionModel(items: [.chat(value)]))
                } else {
                    var items = updatedSections[0].items
                    items.append(.chat(value))
                    updatedSections[0] = ChatRoomSectionModel(items: items)
                }
                self.sections.onNext(updatedSections)
                self.scrollToBottom(animated: true)
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

extension ChatRoomViewController {
    private func presentImagePicker() {
        selectedImageData.removeAll()
        presentYPImagePicker { [weak self] picker, items, cancelled in
            guard let self = self else { return }
            if cancelled {
                picker.dismiss(animated: true)
            } else {
                self.handleImagePickerItems(items)
                picker.dismiss(animated: true)
            }
        }
    }
    
    private func handleImagePickerItems(_ items: [YPMediaItem]) {
        for item in items {
            if case let .photo(photo) = item, let compressedImageData = compressImage(photo.image, quality: 0.5) {
                selectedImageData.append(compressedImageData)
            }
        }
        selectedImageDataSubject.onNext(selectedImageData)
    }
    
    private func compressImage(_ image: UIImage, quality: CGFloat) -> Data? {
        if let imageData = image.jpegData(compressionQuality: quality) {
            return imageData
        } else {
            return nil
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
