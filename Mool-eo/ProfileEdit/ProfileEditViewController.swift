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

class ProfileEditViewController: BaseViewController {
    
    deinit {
        print("‼️ProfileEditViewController Deinit‼️")
    }
    
    let viewModel = ProfileEditViewModel()
    let profileEditView = ProfileEditView()
    
    var nickname: String = ""
    var profileImage: String = ""
    var profileImageData: Data?
    private lazy var selectedImageSubject = BehaviorSubject<Data?>(value: profileImageData)
    
    override func loadView() {
        self.view = profileEditView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setNav() {
        navigationItem.title = "프로필 수정하기"
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = ColorStyle.point
        navigationItem.rightBarButtonItem = profileEditView.completeButton
        navigationItem.leftBarButtonItem = profileEditView.cancelButton
    }
    
    override func configureView() {
        profileEditView.nicknameView.customTextField.text = nickname
        URLImageSettingManager.shared.setImageWithUrl(profileEditView.profileImageView, urlString: profileImage)
    }
    
    override func bind() {
        let profileImageEditButtonTap = profileEditView.profileImageEditButton.rx.tap.asObservable()
        let completeButtonTap = profileEditView.completeButton.rx.tap.asObservable()
        let cancelButtonTap = profileEditView.cancelButton.rx.tap.asObservable()
        let afterNickname = profileEditView.nicknameView.customTextField.rx.text.orEmpty.asObservable()
        let afterProfileImageData = selectedImageSubject
        let input = ProfileEditViewModel.Input(profileImageEditButtonTap: profileImageEditButtonTap, completeButtonTap: completeButtonTap, cancelButtonTap: cancelButtonTap, beforeNickname: nickname, afterNickname: afterNickname, beforeProfileImageData: profileImageData, afterProfileImageData: afterProfileImageData)
        
        let output = viewModel.transform(input: input)
        
        output.profileImageEditButtonTap.drive(with: self) { owner, _ in
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            owner.present(picker, animated: true)
        }.disposed(by: disposeBag)
        
        output.nicknameValidation.drive(with: self) { owner, value in
            owner.profileEditView.nicknameView.descriptionLabel.textColor = value ? ColorStyle.subText : ColorStyle.caution
        }.disposed(by: disposeBag)
        
        output.completeButtonValidation.drive(profileEditView.completeButton.rx.isEnabled).disposed(by: disposeBag)
        
        output.profileEditSuccessTrigger.drive(with: self) { owner, _ in
            NotificationCenter.default.post(name: Notification.Name(Noti.changeProfile.rawValue), object: true)
            owner.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        output.cancelButtonTap.drive(with: self) { owner, _ in
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
                    self.selectedImageSubject.onNext((image as? UIImage)?.pngData())
                }
            }
        }
        picker.dismiss(animated: true)
    }
}
