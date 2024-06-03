//
//  WritePostViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import PhotosUI
import Toast

enum PostInteractionType: String {
    case upload
    case edit
}

final class WritePostViewController: BaseViewController {
    
    deinit {
        print("‼️WritePostViewController Deinit‼️")
    }
    
    let viewModel = WritePostViewModel()
    let writePostView = WritePostView()
    
    var type: PostInteractionType = .upload
    var postBoard: ProductIdentifier = .postBoard
    var postTitle: String = ""
    var postContent: String = ""
    var postFiles: [String] = []
    var postId: String = ""
    
    private var selectedImage: [UIImage] = []
    private var selectedImageData: [Data] = []
    private var selectedImageSubject = BehaviorSubject<[UIImage]>(value: [])
    private var selectedImageDataSubject = BehaviorSubject<[Data]>(value: [])
    private var imageSelected = false
    private var imageSelectedSubject = BehaviorSubject<Bool>(value: false)
    
    override func loadView() {
        self.view = writePostView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setNav() {
        navigationItem.title = "글 쓰기"
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = ColorStyle.point
        writePostView.completeButton.title = type == .upload ? "완료" : "수정"
        navigationItem.rightBarButtonItem = writePostView.completeButton
        navigationItem.leftBarButtonItem = writePostView.cancelButton
    }
    
    // MARK: Hotfix
    override func setToolBar() {
        //navigationController?.isToolbarHidden = type == .upload ? false : true
        if type == .upload {
            let toolbar = UIToolbar()
            toolbar.items = [writePostView.imageAddButton]
            toolbar.sizeToFit()
            writePostView.writePostContentView.titleTextField.inputAccessoryView = toolbar
            writePostView.writePostContentView.contentTextView.inputAccessoryView = toolbar
        } else {
            writePostView.writePostContentView.titleTextField.inputAccessoryView = nil
            writePostView.writePostContentView.contentTextView.inputAccessoryView = nil
        }
    }
    
    override func configureView() {
        switch type {
        case .upload:
            selectedImageSubject.bind(to: writePostView.writePostContentView.collectionView.rx.items(cellIdentifier: WritePostImageCollectionViewCell.identifier, cellType: WritePostImageCollectionViewCell.self)) { (row, element, cell) in
                cell.selectImageView.image = element
                cell.deleteButton.rx.tap.bind(with: self) { owner, _ in
                    // 이미지 삭제
                    guard row < owner.selectedImage.count else { return }
                    owner.selectedImage.remove(at: row)
                    owner.selectedImageSubject.onNext(owner.selectedImage)
                    
                    // 이미지 데이터 삭제
                    guard row < owner.selectedImageData.count else { return }
                    owner.selectedImageData.remove(at: row)
                    owner.selectedImageDataSubject.onNext(owner.selectedImageData)
                    
                    // 이미지 선택 여부 확인
                    if owner.selectedImage.isEmpty {
                        owner.imageSelected = false
                        owner.imageSelectedSubject.onNext(owner.imageSelected)
                    }
                }.disposed(by: cell.disposeBag)
            }.disposed(by: disposeBag)
            writePostView.writePostContentView.contentTextView.text = "내용을 입력해주세요"
            writePostView.writePostContentView.contentTextView.textColor = ColorStyle.placeholder
        case .edit:
            Observable.just(postFiles).bind(to: writePostView.writePostContentView.collectionView.rx.items(cellIdentifier: WritePostImageEditCollectionViewCell.identifier, cellType: WritePostImageEditCollectionViewCell.self)) { (row, element, cell) in
                URLImageSettingManager.shared.setImageWithUrl(cell.selectImageView, urlString: element)
            }.disposed(by: disposeBag)
            writePostView.writePostContentView.titleTextField.text = postTitle
            writePostView.writePostContentView.contentTextView.text = postContent
        }
    }
    
    override func bind() {
        let textViewBegin = writePostView.writePostContentView.contentTextView.rx.didBeginEditing.asObservable()
        let textViewEnd = writePostView.writePostContentView.contentTextView.rx.didEndEditing.asObservable()
        let postBoard = postBoard
        let title = writePostView.writePostContentView.titleTextField.rx.text.orEmpty.asObservable()
        let content = writePostView.writePostContentView.contentTextView.rx.text.orEmpty.asObservable()
        let selectedImageDataSubject = selectedImageDataSubject
        let imageAddButtonTap = writePostView.imageAddButton.rx.tap.asObservable()
        let completeButtonTap = writePostView.completeButton.rx.tap.asObservable()
        let cancelButtonTap = writePostView.cancelButton.rx.tap.asObservable()
        let input = WritePostViewModel.Input(textViewBegin: textViewBegin, textViewEnd: textViewEnd, postBoard: postBoard, title: title, content: content, selectedImageDataSubject: selectedImageDataSubject, imageSelectedSubject: imageSelectedSubject, imageAddButtonTap: imageAddButtonTap, completeButtonTap: completeButtonTap, cancelButtonTap: cancelButtonTap, type: type, postId: Observable.just(postId))
        
        let output = viewModel.transform(input: input)
        
        // 텍스트뷰 placeholder 작업
        output.text.drive(writePostView.writePostContentView.contentTextView.rx.text).disposed(by: disposeBag)
        output.textColorType.drive(with: self) { owner, value in
            owner.writePostView.writePostContentView.contentTextView.textColor = value ? ColorStyle.mainText : ColorStyle.placeholder
        }.disposed(by: disposeBag)
        
        output.imageAddButtonTap.drive(with: self) { owner, _ in
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 3
            configuration.filter = .images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            owner.present(picker, animated: true)
        }.disposed(by: disposeBag)
        
        output.completeButtonValidation.drive(writePostView.completeButton.rx.isEnabled).disposed(by: disposeBag)
        
        output.uploadSuccessTrigger.drive(with: self) { owner, _ in
            NotificationCenter.default.post(name: Notification.Name(Noti.writePost.rawValue), object: postBoard)
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        output.editSuccessTrigger.drive(with: self) { owner, _ in
            NotificationCenter.default.post(name: Notification.Name(Noti.writePost.rawValue), object: postBoard)
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        output.cancelButtonTap.drive(with: self) { owner, _ in
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        output.badRequest.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .badRequestImageUpload, in: owner.writePostView)
        }.disposed(by: disposeBag)
        
        output.notFoundErr.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .notFoundErrPostUpload, in: owner.writePostView)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.writePostView)
        }.disposed(by: disposeBag)
    }
}

extension WritePostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 기존 선택 초기화
        self.selectedImage.removeAll()
        self.selectedImageData.removeAll()
        self.imageSelected = false
        
        for result in results {
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.imageSelected = true
                            self.imageSelectedSubject.onNext(self.imageSelected)
                            self.selectedImage.append(image)
                            self.selectedImageSubject.onNext(self.selectedImage)
                            
                            // 이미지를 압축하여 이미지 데이터에 추가
                            if let compressedImageData = self.compressImage(image, quality: 0.5) {
                                self.selectedImageData.append(compressedImageData)
                                self.selectedImageDataSubject.onNext(self.selectedImageData)
                            }
                        }
                    }
                }
            }
        }
        picker.dismiss(animated: true)
    }
    
    // 이미지 압축 메서드
    func compressImage(_ image: UIImage, quality: CGFloat) -> Data? {
        if let imageData = image.jpegData(compressionQuality: quality) {
            return imageData
        }
        return nil
    }
}

