//
//  ProfileEditViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/18/24.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import PhotosUI
import Toast

final class ProfileEditViewController: BaseViewController {
    
    deinit { print("‼️ProfileEditViewController Deinit‼️") }
    
    let viewModel = ProfileEditViewModel()
    let profileEditView = ProfileEditView()
    
    var nickname: String = ""
    var profileImage: String = ""
    var profileImageData: Data?
    private lazy var selectedImageDataSubject = BehaviorSubject<Data?>(value: profileImageData)
    private let completeButtonTap = PublishSubject<Void>()
    
    override func loadView() {
        self.view = profileEditView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setNav() {
        super.setNav()
        navigationItem.title = "프로필 수정"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(rightBarButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(leftBarButtonTapped))
    }
    
    @objc func rightBarButtonTapped() {
        completeButtonTap.onNext(())
    }
    
    @objc func leftBarButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    override func configureView() {
        profileEditView.nicknameView.customTextField.text = nickname
        URLImageSettingManager.shared.setImageWithUrl(profileEditView.profileImageView, urlString: profileImage, imageViewSize: .medium)
    }
    
    override func bind() {
        let input = ProfileEditViewModel.Input(
            profileImageEditButtonTap: profileEditView.profileImageEditButton.rx.tap.asObservable(),
            completeButtonTap: completeButtonTap,
            beforeNickname: nickname,
            afterNickname: profileEditView.nicknameView.customTextField.rx.text.orEmpty.asObservable(),
            beforeProfileImageData: profileImageData,
            afterProfileImageData: selectedImageDataSubject
        )
        
        let output = viewModel.transform(input: input)
        
        output.profileImageEditButtonTap.drive(with: self) { owner, _ in
            owner.presentPHPicker(delegate: owner, selectionLimit: 1)
        }.disposed(by: disposeBag)
        
        output.nicknameValidation.drive(with: self) { owner, value in
            owner.profileEditView.nicknameView.descriptionLabel.textColor = value ? ColorStyle.subText : ColorStyle.caution
        }.disposed(by: disposeBag)
        
        output.completeButtonValidation.drive(with: self) { owner, value in
            owner.navigationItem.rightBarButtonItem?.isEnabled = value
        }.disposed(by: disposeBag)
        
        output.profileEditSuccessTrigger.drive(with: self) { owner, _ in
            NotificationCenter.default.post(name: Notification.Name(Noti.changeProfile.rawValue), object: true)
            owner.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.profileEditView)
        }.disposed(by: disposeBag)
    }
}

extension ProfileEditViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        guard let result = results.first else { return }
        let itemProvider = result.itemProvider
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    self.profileEditView.profileImageView.image = image as? UIImage
                    self.selectedImageDataSubject.onNext((image as? UIImage)?.pngData())
                }
            }
        }
        picker.dismiss(animated: true)
    }
}
