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
    var postBoard: PostBoardType = .free
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
    
    override func setToolBar() {
        //navigationController?.isToolbarHidden = type == .upload ? false : true
        // MARK: Hotfix
        if type == .upload {
            let toolbar = UIToolbar()
            toolbar.items = [writePostView.imageAddButton]
            toolbar.sizeToFit()
            writePostView.writePostBoxView.titleTextField.inputAccessoryView = toolbar
            writePostView.writePostBoxView.contentTextView.inputAccessoryView = toolbar
        } else {
            writePostView.writePostBoxView.titleTextField.inputAccessoryView = nil
            writePostView.writePostBoxView.contentTextView.inputAccessoryView = nil
        }
    }
    
    override func configureView() {
        switch type {
        case .upload:
            selectedImageSubject.bind(to: writePostView.writePostBoxView.collectionView.rx.items(cellIdentifier: WritePostImageCollectionViewCell.identifier, cellType: WritePostImageCollectionViewCell.self)) { (row, element, cell) in
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
            writePostView.writePostBoxView.contentTextView.text = "내용을 입력해주세요"
            writePostView.writePostBoxView.contentTextView.textColor = ColorStyle.placeholder
        case .edit:
            Observable.just(postFiles).bind(to: writePostView.writePostBoxView.collectionView.rx.items(cellIdentifier: WritePostImageEditCollectionViewCell.identifier, cellType: WritePostImageEditCollectionViewCell.self)) { (row, element, cell) in
                URLImageSettingManager.shared.setImageWithUrl(cell.selectImageView, urlString: element)
            }.disposed(by: disposeBag)
            writePostView.writePostBoxView.titleTextField.text = postTitle
            writePostView.writePostBoxView.contentTextView.text = postContent
        }
    }
    
    override func bind() {
        let textViewBegin = writePostView.writePostBoxView.contentTextView.rx.didBeginEditing.asObservable()
        let textViewEnd = writePostView.writePostBoxView.contentTextView.rx.didEndEditing.asObservable()
        let keyboardWillShow = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification) // 키보드가 나타나는 시점
        let keyboardWillHide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification) // 키보드가 사라지는 시점
        let postBoard = postBoard
        let title = writePostView.writePostBoxView.titleTextField.rx.text.orEmpty.asObservable()
        let content = writePostView.writePostBoxView.contentTextView.rx.text.orEmpty.asObservable()
        let selectedImageDataSubject = selectedImageDataSubject
        let imageAddButtonTap = writePostView.imageAddButton.rx.tap.asObservable()
        let completeButtonTap = writePostView.completeButton.rx.tap.asObservable()
        let cancelButtonTap = writePostView.cancelButton.rx.tap.asObservable()
        let input = WritePostViewModel.Input(textViewBegin: textViewBegin, textViewEnd: textViewEnd, keyboardWillShow: keyboardWillShow, keyboardWillHide: keyboardWillHide, postBoard: postBoard, title: title, content: content, selectedImageDataSubject: selectedImageDataSubject, imageSelectedSubject: imageSelectedSubject, imageAddButtonTap: imageAddButtonTap, completeButtonTap: completeButtonTap, cancelButtonTap: cancelButtonTap, type: type, postId: Observable.just(postId))
        
        let output = viewModel.transform(input: input)
        
        // 텍스트뷰 placeholder 작업
        output.text.drive(writePostView.writePostBoxView.contentTextView.rx.text).disposed(by: disposeBag)
        output.textColorType.drive(with: self) { owner, value in
            owner.writePostView.writePostBoxView.contentTextView.textColor = value ? ColorStyle.mainText : ColorStyle.placeholder
        }.disposed(by: disposeBag)
        
        // 키보드가 나타났을 경우
        output.keyboardWillShow.bind(with: self) { owner, notification in
            owner.keyboardWillShow(notification: notification)
        }.disposed(by: disposeBag)
        
        // 키보드가 사라졌을 경우
        output.keyboardWillHide.bind(with: self) { owner, notification in
            owner.keyboardWillHide(notification: notification)
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
    
    func keyboardWillShow(notification: Notification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardHeight = keyboardFrame.size.height
        
        var contentInset = writePostView.scrollView.contentInset
        contentInset.bottom = keyboardHeight
        writePostView.scrollView.contentInset = contentInset
        writePostView.scrollView.scrollIndicatorInsets = contentInset
    }
    
    func keyboardWillHide(notification: Notification) {
        writePostView.scrollView.contentInset = .zero
        writePostView.scrollView.scrollIndicatorInsets = .zero
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
                        }
                        if let imageData = image.pngData() {
                            self.selectedImageData.append(imageData)
                            self.selectedImageDataSubject.onNext(self.selectedImageData)
                        }
                    }
                }
            }
        }
        picker.dismiss(animated: true)
    }
}
