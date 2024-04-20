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

final class WritePostViewController: BaseViewController {
    
    let completeButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "완료"
        return button
    }()
    
    let cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "xmark")
        return button
    }()
    
    let disposeBag = DisposeBag()
    let viewModel = WritePostViewModel()
    let writePostView = WritePostView()
    
    var postBoard: PostBoardType = .free
    
    private var selectedImageSubject = PublishSubject<[UIImage]>()
    private var selectedImageDataSubject = PublishSubject<[Data]>()
    
    override func loadView() {
        self.view = writePostView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNav()
    }
    
    override func configureView() {
        selectedImageSubject.bind(to: writePostView.writePostBoxView.collectionView.rx.items(cellIdentifier: WritePostImageCollectionViewCell.identifier, cellType: WritePostImageCollectionViewCell.self)) { (row, element, cell) in
            cell.selectImageView.image = element
        }.disposed(by: disposeBag)
    }
    
    override func bind() {
        let postBoard = postBoard
        let content = writePostView.writePostBoxView.contentTextView.rx.text.orEmpty.asObservable()
        let textViewBegin = writePostView.writePostBoxView.contentTextView.rx.didBeginEditing.asObservable()
        let textViewEnd = writePostView.writePostBoxView.contentTextView.rx.didEndEditing.asObservable()
        let imageAddButtonTap = writePostView.writePostBoxView.imageAddButton.rx.tap.asObservable()
        let selectedImageDataSubject = selectedImageDataSubject
        let title = writePostView.writePostBoxView.titleTextField.rx.text.orEmpty.asObservable()
        let completeButtonTap = completeButton.rx.tap.asObservable()
        let cancelButtonTap = cancelButton.rx.tap.asObservable()
        let input = WritePostViewModel.Input(postBoard: postBoard, content: content, textViewBegin: textViewBegin, textViewEnd: textViewEnd, imageAddButtonTap: imageAddButtonTap, selectedImageDataSubject: selectedImageDataSubject, title: title, completeButtonTap: completeButtonTap)
        
        let output = viewModel.transform(input: input)
        output.text.drive(writePostView.writePostBoxView.contentTextView.rx.text).disposed(by: disposeBag)
        output.textColorType.drive(with: self) { owner, value in
            owner.writePostView.writePostBoxView.contentTextView.textColor = value ? ColorStyle.mainText : ColorStyle.placeholder
        }.disposed(by: disposeBag)
        
        output.imageAddButtonTap.bind(with: self) { owner, _ in
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 3
            configuration.filter = .images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            owner.present(picker, animated: true)
        }.disposed(by: disposeBag)
        
        output.uploadSuccessTrigger.bind(with: self) { owner, _ in
            print("업로드 성공")
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
    }
    
    func setNav() {
        navigationItem.title = "글 쓰기"
        navigationItem.rightBarButtonItem = completeButton
        navigationItem.leftBarButtonItem = cancelButton
    }
}

extension WritePostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        var selectedImage: [UIImage] = []
        var selectedImagesData: [Data] = []
        
        for result in results {
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            selectedImage.append(image)
                            self.selectedImageSubject.onNext(selectedImage)
                        }
                        if let imageData = image.pngData() {
                            selectedImagesData.append(imageData)
                            self.selectedImageDataSubject.onNext(selectedImagesData)
                        }
                    }
                }
            }
        }
        picker.dismiss(animated: true)
    }
}
