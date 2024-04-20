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
    let viewModel = ProfileEditViewModel()
    let profileEditView = ProfileEditView()
    
    var nickname: String = ""
    var introduction: String = ""
    var profileImage: String = ""
    var profileImageData: Data?
    
    private lazy var selectedImageSubject = BehaviorSubject<Data?>(value: profileImageData)
    
    override func loadView() {
        self.view = profileEditView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNav()
    }
    
    override func configureView() {
        profileEditView.nicknameView.customTextField.text = nickname
        profileEditView.introductionView.customTextField.text = introduction
        let url = URL(string: APIKey.baseURL.rawValue + profileImage)
        let modifier = AnyModifier { request in
            var urlRequest = request
            urlRequest.headers = [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
                                  HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
            return urlRequest
        }
        profileEditView.profileImageView.kf.setImage(with: url, options: [.requestModifier(modifier)])
    }
    
    override func bind() {
        let profileImageEditButtonTap = profileEditView.profileImageEditButton.rx.tap.asObservable()
        let cancelButtonTap = cancelButton.rx.tap.asObservable()
        let completeButtonTap = completeButton.rx.tap.asObservable()
        let beforeNickname = nickname
        let afterNickname = profileEditView.nicknameView.customTextField.rx.text.orEmpty.asObservable()
        let changeNickname = profileEditView.nicknameView.customTextField.rx.controlEvent(.editingChanged).asObservable()
        let beforeIntroduction = introduction
        let afterIntroduction = profileEditView.introductionView.customTextField.rx.text.orEmpty.asObservable()
        let changeIntroduction = profileEditView.introductionView.customTextField.rx.controlEvent(.editingChanged).asObservable()
        let beforeProfileImageData = profileImageData
        let afterProfileImageData = selectedImageSubject
        
        let input = ProfileEditViewModel.Input(profileImageEditButtonTap: profileImageEditButtonTap,
                                               completeButtonTap: completeButtonTap,
                                               cancelButtonTap: cancelButtonTap,
                                               beforeNickname: beforeNickname, afterNickname: afterNickname, changeNickname: changeNickname,
                                               beforeIntroduction: beforeIntroduction, afterIntroduction: afterIntroduction, changeIntroduction: changeIntroduction,
                                               beforeProfileImageData: beforeProfileImageData, afterProfileImageData: afterProfileImageData)
        
        
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
        
        output.completeButtonValidation.drive(completeButton.rx.isEnabled).disposed(by: disposeBag)
        
        output.profileEditSuccessTrigger.bind(with: self) { owner, _ in
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let sceneDelegate = windowScene?.delegate as? SceneDelegate
            let vc = ProfileViewController()
            vc.showProfileUpdateAlert = true
            sceneDelegate?.window?.rootViewController = UINavigationController(rootViewController: vc)
            sceneDelegate?.window?.makeKeyAndVisible()
        }.disposed(by: disposeBag)
        
        output.cancelButtonTap.bind(with: self) { owner, _ in
            owner.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    func setNav() {
        navigationItem.title = "프로필 수정하기"
        navigationItem.rightBarButtonItem = completeButton
        navigationItem.leftBarButtonItem = cancelButton
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
