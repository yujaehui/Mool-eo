//
//  WriteProductPostViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import PhotosUI
import Toast

class WriteProductPostViewController: BaseViewController {
    
    deinit {
        print("‼️WriteProductPostViewController Deinit‼️")
    }
    
    let viewModel = WriteProductPostViewModel()
    let writeProductPostView = WriteProductPostView()
    
    private var selectedImage: [UIImage] = []
    private var selectedImageData: [Data] = []
    private var selectedImageSubject = BehaviorSubject<[UIImage]>(value: [])
    private var selectedImageDataSubject = BehaviorSubject<[Data]>(value: [])
    
    private var selectedCategory = BehaviorSubject<String>(value: "")
    
    override func loadView() {
        self.view = writeProductPostView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setNav() {
        navigationItem.title = "상품 등록"
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = ColorStyle.point
        writeProductPostView.completeButton.title = "완료"
        navigationItem.rightBarButtonItem = writeProductPostView.completeButton
        navigationItem.leftBarButtonItem = writeProductPostView.cancelButton
    }
    
    override func configureView() {
        selectedImageSubject.bind(to: writeProductPostView.writeProductPostContentView.collectionView.rx.items(cellIdentifier: WritePostImageCollectionViewCell.identifier, cellType: WritePostImageCollectionViewCell.self)) { (row, element, cell) in
            cell.selectImageView.image = element
            cell.deleteButton.rx.tap.bind(with: self) { owner, _ in
                
                guard row < owner.selectedImage.count else { return }
                owner.selectedImage.remove(at: row)
                owner.selectedImageSubject.onNext(owner.selectedImage)
                
                guard row < owner.selectedImageData.count else { return }
                owner.selectedImageData.remove(at: row)
                owner.selectedImageDataSubject.onNext(owner.selectedImageData)
                
            }.disposed(by: cell.disposeBag)
        }.disposed(by: disposeBag)
        
        writeProductPostView.writeProductPostContentView.categoryStackView.rx.tapGesture().bind(with: self) { owner, _ in
            let vc = ProductCategoryViewController()
            vc.selectedCategory = { value in
                owner.selectedCategory.onNext(value)
                owner.writeProductPostView.writeProductPostContentView.categoryLabel.text = value
            }
            let nav = UINavigationController(rootViewController: vc)
            if let sheet = nav.sheetPresentationController { sheet.detents = [.medium()] }
            owner.present(nav, animated: true)
        }.disposed(by: disposeBag)
    }
    
    override func bind() {
        let textViewBegin = writeProductPostView.writeProductPostContentView.detailTextView.rx.didBeginEditing.asObservable()
        let textViewEnd = writeProductPostView.writeProductPostContentView.detailTextView.rx.didEndEditing.asObservable()
        let selectedImageDataSubject = selectedImageDataSubject
        let category = selectedCategory
        let productName = writeProductPostView.writeProductPostContentView.productNameView.customTextField.rx.text.orEmpty.asObservable()
        let price = writeProductPostView.writeProductPostContentView.priceView.customTextField.rx.text.orEmpty.asObservable()
        let detail = writeProductPostView.writeProductPostContentView.detailTextView.rx.text.orEmpty.asObservable()
        let imageAddButtonTap = writeProductPostView.writeProductPostContentView.imageAddButton.rx.tap.asObservable()
        let completeButtonTap = writeProductPostView.completeButton.rx.tap.asObservable()
        let cancelButtonTap = writeProductPostView.cancelButton.rx.tap.asObservable()
    
        let input = WriteProductPostViewModel.Input(textViewBegin: textViewBegin, textViewEnd: textViewEnd, selectedImageDataSubject: selectedImageDataSubject, category: category, productName: productName, price: price, detail: detail, imageAddButtonTap: imageAddButtonTap, completeButtonTap: completeButtonTap, cancelButtonTap: cancelButtonTap)
        
        let output = viewModel.transform(input: input)
        
        output.text.drive(writeProductPostView.writeProductPostContentView.detailTextView.rx.text).disposed(by: disposeBag)
        output.textColorType.drive(with: self) { owner, value in
            owner.writeProductPostView.writeProductPostContentView.detailTextView.textColor = value ? ColorStyle.mainText : ColorStyle.placeholder
        }.disposed(by: disposeBag)
        
        output.imageAddButtonTap.drive(with: self) { owner, _ in
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 5
            configuration.filter = .images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            owner.present(picker, animated: true)
        }.disposed(by: disposeBag)
        
        output.completeButtonValidation.drive(writeProductPostView.completeButton.rx.isEnabled).disposed(by: disposeBag)
        
        output.uploadSuccessTrigger.drive(with: self) { owner, _ in
            NotificationCenter.default.post(name: Notification.Name(Noti.writeProduct.rawValue), object: nil)
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        output.cancelButtonTap.drive(with: self) { owner, _ in
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        output.badRequest.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .badRequestImageUpload, in: owner.writeProductPostView)
        }.disposed(by: disposeBag)
        
        output.notFoundErr.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .notFoundErrPostUpload, in: owner.writeProductPostView)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.writeProductPostView)
        }.disposed(by: disposeBag)
        
    }
}

extension WriteProductPostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 기존 선택 초기화
        self.selectedImage.removeAll()
        self.selectedImageData.removeAll()
        
        for result in results {
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
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

