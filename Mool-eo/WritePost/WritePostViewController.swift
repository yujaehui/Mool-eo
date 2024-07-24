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
    
    deinit { print("‼️WritePostViewController Deinit‼️") }
    
    let viewModel = WritePostViewModel()
    let writePostView = WritePostView()
    
    var type: PostInteractionType = .upload
    var postTitle: String = ""
    var postContent: String = ""
    var postFiles: [String] = []
    var postId: String = ""
    
    private var selectedImage: [UIImage] = []
    private var selectedImageData: [Data] = []
    private var selectedImageSubject = BehaviorSubject<[UIImage]>(value: [])
    private var selectedImageDataSubject = BehaviorSubject<[Data]>(value: [])
    
    private var completeButtonTap = PublishSubject<Void>()
    
    override func loadView() {
        self.view = writePostView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setNav() {
        super.setNav()
        navigationItem.title = "글쓰기"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: type == .upload ? "완료" : "수정", style: .plain, target: self, action: #selector(rightBarButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(leftBarButtonTapped))
    }
    
    @objc func rightBarButtonTapped() {
        completeButtonTap.onNext(())
    }
    
    @objc func leftBarButtonTapped() {
        dismiss(animated: true)
    }
    
    override func setToolBar() {
        writePostView.writePostContentView.titleTextField.inputAccessoryView?.isHidden = type == .edit ? true : false
        writePostView.writePostContentView.contentTextView.inputAccessoryView?.isHidden = type == .edit ? true : false
    }
    
    override func configureView() {
        switch type {
        case .upload:
            selectedImageSubject.bind(to: writePostView.writePostContentView.collectionView.rx.items(cellIdentifier: WritePostImageCollectionViewCell.identifier, cellType: WritePostImageCollectionViewCell.self)) { (row, element, cell) in
                cell.selectImageView.image = element.downsample(to: .large)
                cell.deleteButton.rx.tap.bind(with: self) { owner, _ in
                    // 이미지 삭제
                    guard row < owner.selectedImage.count else { return }
                    owner.selectedImage.remove(at: row)
                    owner.selectedImageSubject.onNext(owner.selectedImage)
                    
                    // 이미지 데이터 삭제
                    guard row < owner.selectedImageData.count else { return }
                    owner.selectedImageData.remove(at: row)
                    owner.selectedImageDataSubject.onNext(owner.selectedImageData)
                }.disposed(by: cell.disposeBag)
            }.disposed(by: disposeBag)
            
            writePostView.writePostContentView.contentTextView.text = "내용을 입력해주세요"
            writePostView.writePostContentView.contentTextView.textColor = ColorStyle.placeholder
            
        case .edit:
            Observable.just(postFiles).bind(to: writePostView.writePostContentView.collectionView.rx.items(cellIdentifier: WritePostImageEditCollectionViewCell.identifier, cellType: WritePostImageEditCollectionViewCell.self)) { (row, element, cell) in
                URLImageSettingManager.shared.setImageWithUrl(cell.selectImageView, urlString: element, imageViewSize: .large)
            }.disposed(by: disposeBag)
            
            writePostView.writePostContentView.titleTextField.text = postTitle
            writePostView.writePostContentView.contentTextView.text = postContent
        }
    }
    
    override func bind() {
        let input = WritePostViewModel.Input(
            contentTextViewBegin: writePostView.writePostContentView.contentTextView.rx.didBeginEditing.asObservable(),
            contentTextViewEnd: writePostView.writePostContentView.contentTextView.rx.didEndEditing.asObservable(),
            title: writePostView.writePostContentView.titleTextField.rx.text.orEmpty.asObservable(),
            content: writePostView.writePostContentView.contentTextView.rx.text.orEmpty.asObservable(),
            selectedImageDataSubject: selectedImageDataSubject,
            imageAddButtonTap: writePostView.writePostContentView.imageAddButton.rx.tap.asObservable(),
            completeButtonTap: completeButtonTap,
            type: type,
            postId: Observable.just(postId)
        )
        
        let output = viewModel.transform(input: input)
        
        output.contentText.drive(writePostView.writePostContentView.contentTextView.rx.text).disposed(by: disposeBag)
        
        output.contentTextColorType.drive(with: self) { owner, value in
            owner.writePostView.writePostContentView.contentTextView.textColor = value ? ColorStyle.mainText : ColorStyle.placeholder
        }.disposed(by: disposeBag)
        
        output.imageAddButtonTap.drive(with: self) { owner, _ in
            owner.presentPHPicker(delegate: owner, selectionLimit: 3)
        }.disposed(by: disposeBag)
        
        output.completeButtonValidation.drive(with: self) { owner, value in
            owner.navigationItem.rightBarButtonItem?.isEnabled = value
        }.disposed(by: disposeBag)
        
        output.uploadSuccessTrigger.drive(with: self) { owner, _ in
            NotificationCenter.default.post(name: Notification.Name(Noti.writePost.rawValue), object: ProductIdentifier.post)
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        output.editSuccessTrigger.drive(with: self) { owner, _ in
            NotificationCenter.default.post(name: Notification.Name(Noti.writePost.rawValue), object: ProductIdentifier.post)
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.writePostView)
        }.disposed(by: disposeBag)
    }
}

extension WritePostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            // 기존 선택 초기화
            self.selectedImage.removeAll()
            self.selectedImageData.removeAll()

            let group = DispatchGroup()

            for result in results {
                group.enter()
                let itemProvider = result.itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        defer { group.leave() }

                        guard let self = self, let image = image as? UIImage else { return }

                        // 이미지 다운샘플링
                        autoreleasepool {
                            if let downsampledImage = image.downsample(to: .large) {
                                DispatchQueue.main.async {
                                    self.selectedImage.append(downsampledImage)
                                    self.selectedImageSubject.onNext(self.selectedImage)
                                }
                            }

                            // 이미지를 압축하여 이미지 데이터에 추가
                            if let compressedImageData = self.compressImage(image, quality: 0.5) {
                                DispatchQueue.main.async {
                                    self.selectedImageData.append(compressedImageData)
                                    self.selectedImageDataSubject.onNext(self.selectedImageData)
                                }
                            }
                        }

                    }
                } else {
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                picker.dismiss(animated: true)
            }
        }
    }

    func compressImage(_ image: UIImage, quality: CGFloat) -> Data? {
        if let imageData = image.jpegData(compressionQuality: quality) {
            return imageData
        } else {
            return nil
        }
    }
}


