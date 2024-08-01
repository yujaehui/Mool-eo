//
//  WriteProductViewController.swift
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

final class WriteProductViewController: BaseViewController {
    
    deinit {
        print("‼️WriteProductViewController Deinit‼️")
    }
    
    let viewModel = WriteProductViewModel()
    let writeProductView = WriteProductView()
    
    private var selectedImage: [UIImage] = []
    private var selectedImageData: [Data] = []
    private var selectedImageSubject = BehaviorSubject<[UIImage]>(value: [])
    private var selectedImageDataSubject = BehaviorSubject<[Data]>(value: [])
    
    private var selectedCategory = BehaviorSubject<String>(value: "")
    private var completeButtonTap = PublishSubject<Void>()
    
    override func loadView() {
        self.view = writeProductView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setNav() {
        super.setNav()
        navigationItem.title = "상품 등록"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(rightBarButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(leftBarButtonTapped))
    }
    
    @objc private func rightBarButtonTapped() {
        completeButtonTap.onNext(())
    }
    
    @objc private func leftBarButtonTapped() {
        dismiss(animated: true)
    }
    
    override func configureView() {
        selectedImageSubject
            .bind(to: writeProductView.writeProductPostContentView.collectionView.rx.items(cellIdentifier: WritePostImageCollectionViewCell.identifier, cellType: WritePostImageCollectionViewCell.self)) { (row, element, cell) in
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
        
        writeProductView.writeProductPostContentView.categoryStackView.rx.tapGesture()
            .bind(with: self) { owner, _ in
                let vc = ProductCategoryViewController()
                vc.selectedCategory = { value in
                    owner.selectedCategory.onNext(value)
                    owner.writeProductView.writeProductPostContentView.categoryLabel.text = value
                }
                let nav = UINavigationController(rootViewController: vc)
                if let sheet = nav.sheetPresentationController { sheet.detents = [.medium()] }
                owner.present(nav, animated: true)
            }.disposed(by: disposeBag)
    }
    
    override func bind() {
        let input = WriteProductViewModel.Input(
            textViewBegin: writeProductView.writeProductPostContentView.productDetailTextView.rx.didBeginEditing.asObservable(),
            textViewEnd: writeProductView.writeProductPostContentView.productDetailTextView.rx.didEndEditing.asObservable(),
            selectedImageDataSubject: selectedImageDataSubject,
            productCategory: selectedCategory,
            productName: writeProductView.writeProductPostContentView.productNameView.customTextField.rx.text.orEmpty.asObservable(),
            productPrice: writeProductView.writeProductPostContentView.productPriceView.customTextField.rx.text.orEmpty.asObservable(),
            productDetail: writeProductView.writeProductPostContentView.productDetailTextView.rx.text.orEmpty.asObservable(),
            imageAddButtonTap: writeProductView.writeProductPostContentView.imageAddButton.rx.tap.asObservable(),
            completeButtonTap: completeButtonTap
        )
        
        let output = viewModel.transform(input: input)
        
        output.text.drive(writeProductView.writeProductPostContentView.productDetailTextView.rx.text).disposed(by: disposeBag)
        
        output.textColorType.drive(with: self) { owner, value in
            owner.writeProductView.writeProductPostContentView.productDetailTextView.textColor = value ? ColorStyle.mainText : ColorStyle.placeholder
        }.disposed(by: disposeBag)
        
        output.imageAddButtonTap.drive(with: self) { owner, _ in
            owner.presentPHPicker(delegate: owner, selectionLimit: 5)
        }.disposed(by: disposeBag)
        
        output.convertedProductPrice.drive(with: self) { owner, value in
            owner.writeProductView.writeProductPostContentView.productPriceView.customTextField.text = value
        }.disposed(by: disposeBag)
        
        output.completeButtonValidation.drive(with: self) { owner, value in
            owner.navigationItem.rightBarButtonItem?.isEnabled = value
        }.disposed(by: disposeBag)
        
        output.uploadSuccessTrigger.bind(with: self) { owner, _ in
            NotificationCenter.default.post(name: Notification.Name(Noti.writeProduct.rawValue), object: nil)
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        output.badRequest.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .badRequestImageUpload, in: owner.writeProductView)
        }.disposed(by: disposeBag)
        
        output.notFoundErr.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .notFoundErrPostUpload, in: owner.writeProductView)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.writeProductView)
        }.disposed(by: disposeBag)
    }
}

extension WriteProductViewController: PHPickerViewControllerDelegate {
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
                        
                        autoreleasepool {
                            if let downsampledImage = image.downsample(to: .screenWidth),
                               let downsampleImageData = downsampledImage.pngData() {
                                DispatchQueue.main.async {
                                    self.selectedImage.append(downsampledImage)
                                    self.selectedImageSubject.onNext(self.selectedImage)
                                    self.selectedImageData.append(downsampleImageData)
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
}
