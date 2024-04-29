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
    }
    
    override func bind() {
        selectedImageSubject.bind(to: writePostView.writePostBoxView.collectionView.rx.items(cellIdentifier: WritePostImageCollectionViewCell.identifier, cellType: WritePostImageCollectionViewCell.self)) { (row, element, cell) in
            cell.selectImageView.image = element
        }.disposed(by: disposeBag)
        
        let textViewBegin = writePostView.writePostBoxView.contentTextView.rx.didBeginEditing.asObservable()
        let textViewEnd = writePostView.writePostBoxView.contentTextView.rx.didEndEditing.asObservable()
        let postBoard = postBoard
        let title = writePostView.writePostBoxView.titleTextField.rx.text.orEmpty.asObservable()
        let content = writePostView.writePostBoxView.contentTextView.rx.text.orEmpty.asObservable()
        let selectedImageDataSubject = selectedImageDataSubject
        let imageAddButtonTap = writePostView.imageAddButton.rx.tap.asObservable()
        let completeButtonTap = writePostView.completeButton.rx.tap.asObservable()
        let cancelButtonTap = writePostView.cancelButton.rx.tap.asObservable()
        let input = WritePostViewModel.Input(textViewBegin: textViewBegin, textViewEnd: textViewEnd, postBoard: postBoard, title: title, content: content, selectedImageDataSubject: selectedImageDataSubject, imageAddButtonTap: imageAddButtonTap, completeButtonTap: completeButtonTap, cancelButtonTap: cancelButtonTap)
        
        let output = viewModel.transform(input: input)
        
        // 텍스트뷰 placeholder 작업
        output.text.drive(writePostView.writePostBoxView.contentTextView.rx.text).disposed(by: disposeBag)
        output.textColorType.drive(with: self) { owner, value in
            owner.writePostView.writePostBoxView.contentTextView.textColor = value ? ColorStyle.mainText : ColorStyle.placeholder
        }.disposed(by: disposeBag)
        
        output.imageAddButtonTap.drive(with: self) { owner, _ in
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 3
            configuration.filter = .images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            owner.present(picker, animated: true)
        }.disposed(by: disposeBag)
        
        output.uploadSuccessTrigger.drive(with: self) { owner, _ in
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        output.cancelButtonTap.drive(with: self) { owner, _ in
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
    }
    
    override func setNav() {
        navigationItem.title = "글 쓰기"
        navigationItem.rightBarButtonItem = writePostView.completeButton
        navigationItem.leftBarButtonItem = writePostView.cancelButton
    }
    
    override func setToolBar() {
        navigationController?.isToolbarHidden = false
        let barItems = [writePostView.imageAddButton]
        self.toolbarItems = barItems
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
