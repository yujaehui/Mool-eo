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
    
    private var selectedImageData: [Data] = []
    private var selectedImageDataSubject = BehaviorSubject<[Data]>(value: [])
    
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
        let newChat = chatRoomView.writeMessageView.writeTextView.rx.text.orEmpty.asObservable()
        let newChatUploadButtonTap = chatRoomView.writeMessageView.textUploadButton.rx.tap.asObservable()
        let newChatImageSelectButtonTap = chatRoomView.writeMessageView.imageSelectButton.rx.tap.asObservable()
        let intput = ChatRoomViewModel.Input(userId: userId, roomId: roomId, newChat: newChat, newChatUploadButtonTap: newChatUploadButtonTap, newChatImageSelectButtonTap: newChatImageSelectButtonTap, selectedImageDataSubject: selectedImageDataSubject)
        let output = viewModel.transform(input: intput)
        output.chatRoom.bind(with: self) { owner, value in
            owner.roomId.onNext(value.roomID)
        }.disposed(by: disposeBag)
        
        output.chatList.bind(with: self) { owner, value in
            owner.sections.onNext([ChatRoomSectionModel(items: value.map { .chat($0) })])
            if !value.isEmpty {
                owner.scrollToBottom(animated: false)
            }
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
            owner.chatRoomView.writeMessageView.writeTextView.text = ""
        }.disposed(by: disposeBag)
        
        output.newChatImageSelectButtonTap.bind(with: self) { owner, _ in
            
            self.selectedImageData.removeAll()
            
            var config = YPImagePickerConfiguration()
            config.wordings.next = "전송"
            config.wordings.cancel = "취소"
            config.screens = [.library]
            config.startOnScreen = .library
            config.library.maxNumberOfItems = 5
            config.library.mediaType = .photo
            config.library.skipSelectionsGallery = true
            config.showsPhotoFilters = false
            let picker = YPImagePicker(configuration: config)
            picker.didFinishPicking { [unowned picker] items, cancelled in
                for item in items {
                    switch item {
                    case .photo(let photo): 
                        if let compressedImageData = owner.compressImage(photo.image, quality: 0.5) {
                            owner.selectedImageData.append(compressedImageData)
                        }
                    default: print("")
                    }
                }
                owner.selectedImageDataSubject.onNext(owner.selectedImageData)
                picker.dismiss(animated: true)
            }
            owner.present(picker, animated: true)
        }.disposed(by: disposeBag)
        
        output.isTextEmpty.bind(with: self) { owner, isTextEmpty in
            owner.chatRoomView.writeMessageView.updateButtonVisibility(isTextEmpty: isTextEmpty)
        }.disposed(by: disposeBag)
    }
    
    private func configureDataSource() -> RxTableViewSectionedReloadDataSource<ChatRoomSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<ChatRoomSectionModel> (configureCell : { dataSource, tableView, indexPath, item in
            switch item {
            case .chat(let chat):
                if chat.sender?.user_id == UserDefaultsManager.userId  && chat.filesArray.isEmpty {
                    let cell = tableView.dequeueReusableCell(withIdentifier: MyChatTableViewCell.identifier, for: indexPath) as! MyChatTableViewCell
                    cell.configureCell(chat)
                    return cell
                } else if chat.sender?.user_id == UserDefaultsManager.userId && !chat.filesArray.isEmpty {
                    let cell = tableView.dequeueReusableCell(withIdentifier: MyImageChatTableViewCell.identifier, for: indexPath) as! MyImageChatTableViewCell
                    Observable.just(chat.filesArray).bind(to: cell.collectionView.rx.items(cellIdentifier: MyImageChatCollectionViewCell.identifier, cellType: MyImageChatCollectionViewCell.self)) { (row, element, cell) in
                        URLImageSettingManager.shared.setImageWithUrl(cell.chatImageView, urlString: element)
                    }.disposed(by: cell.disposeBag)
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
    
    func compressImage(_ image: UIImage, quality: CGFloat) -> Data? {
        if let imageData = image.jpegData(compressionQuality: quality) {
            return imageData
        }
        return nil
    }
}
