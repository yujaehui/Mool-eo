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


class ProfileEditViewController: BaseViewController {
    
    let viewModel = ProfileEditViewModel()
    let profileEditView = ProfileEditView()
    
    var nickname: String = ""
    var introduction: String = ""
    var profileImageData: Data?
    var profileImage: String = ""
    
    private lazy var selectedImageSubject = BehaviorSubject<Data?>(value: profileImageData)
    
    override func loadView() {
        self.view = profileEditView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureView() {
        profileEditView.nicknameView.customTextField.text = nickname
        profileEditView.introductionView.customTextField.text = introduction
        URLImageSettingManager.shared.setImageWithUrl(profileEditView.profileImageView, urlString: profileImage)
    }
    
    override func bind() {
        let profileImageEditButtonTap = profileEditView.profileImageEditButton.rx.tap.asObservable()
        let completeButtonTap = profileEditView.completeButton.rx.tap.asObservable()
        let cancelButtonTap = profileEditView.cancelButton.rx.tap.asObservable()
        let afterNickname = profileEditView.nicknameView.customTextField.rx.text.orEmpty.asObservable()
        let afterIntroduction = profileEditView.introductionView.customTextField.rx.text.orEmpty.asObservable()
        let afterProfileImageData = selectedImageSubject
        let input = ProfileEditViewModel.Input(profileImageEditButtonTap: profileImageEditButtonTap, completeButtonTap: completeButtonTap, cancelButtonTap: cancelButtonTap, beforeNickname: nickname, afterNickname: afterNickname, beforeIntroduction: introduction, afterIntroduction: afterIntroduction, beforeProfileImageData: profileImageData, afterProfileImageData: afterProfileImageData)
        
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
        
        output.introductionValidation.drive(with: self) { owner, value in
            owner.profileEditView.introductionView.descriptionLabel.textColor = value ? ColorStyle.subText : ColorStyle.caution
        }.disposed(by: disposeBag)
        
        output.completeButtonValidation.drive(profileEditView.completeButton.rx.isEnabled).disposed(by: disposeBag)
        
        output.profileEditSuccessTrigger.drive(with: self) { owner, _ in
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let sceneDelegate = windowScene?.delegate as? SceneDelegate
            let vc = ProfileViewController()
            vc.showProfileUpdateAlert = true
            sceneDelegate?.window?.rootViewController = UINavigationController(rootViewController: vc)
            sceneDelegate?.window?.makeKeyAndVisible()
        }.disposed(by: disposeBag)
        
        output.cancelButtonTap.drive(with: self) { owner, _ in
            owner.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    override func setNav() {
        navigationItem.title = "프로필 수정하기"
        navigationItem.rightBarButtonItem = profileEditView.completeButton
        navigationItem.leftBarButtonItem = profileEditView.cancelButton
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
