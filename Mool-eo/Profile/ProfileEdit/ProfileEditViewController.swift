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
    
    let disposeBag = DisposeBag()
    let viewModel = ProfileEditViewModel()
    let profileEditView = ProfileEditView()
    
    var profileImage: String = ""
    var name: String = ""
    var birthday: String = ""
    
    override func loadView() {
        self.view = profileEditView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNav()
    }
    
    override func bind() {
        let name = Observable.just(name)
        let birthday = Observable.just(birthday)
        let profileImage = Observable.just(profileImage)
        let profileImageEditButtonTap = profileEditView.profileImageEditButton.rx.tap.asObservable()
        let input = ProfileEditViewModel.Input(name: name, birthday: birthday, profileImage: profileImage, profileImageEditButtonTap: profileImageEditButtonTap)
        
        let output = viewModel.transform(input: input)
        output.name.drive(profileEditView.nameTextField.rx.text).disposed(by: disposeBag)
        output.birthday.drive(profileEditView.birthdayTextField.rx.text).disposed(by: disposeBag)
        output.profileImage.drive(with: self) { owner, value in
            let url = URL(string: APIKey.baseURL.rawValue + value)
            let modifier = AnyModifier { request in
                var urlRequest = request
                urlRequest.headers = [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
                                      HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
                return urlRequest
            }
            owner.profileEditView.profileImageView.kf.setImage(with: url, options: [.requestModifier(modifier)])
        }.disposed(by: disposeBag)
        output.profileImageEditButtonTap.drive(with: self) { owner, _ in
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            owner.present(picker, animated: true)
        }.disposed(by: disposeBag)
    }
    
    func setNav() {
        navigationItem.title = "프로필 수정하기"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(leftBarButtonTap))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(rightBarButtonTap))
    }
    
    @objc func leftBarButtonTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func rightBarButtonTap() {
        guard let profileImage = profileEditView.profileImageView.image?.pngData() else { return }
        let profileImageData = Observable.just(profileImage)
        let name = profileEditView.nameTextField.rx.text.orEmpty.asObservable()
        let birthday = profileEditView.birthdayTextField.rx.text.orEmpty.asObservable()
        Observable.combineLatest(profileImageData, name, birthday)
            .map { (image, name, birthday) in
                return ProfileEditQuery(nick: name, birthDay: birthday, profile: image)
            }
            .flatMap { query in
                NetworkManager.profileEdit(query: query)
            }
            .debug("ProfileEdit")
            .subscribe(with: self) { owner, value in
                print("프로필 수정 성공")
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let sceneDelegate = windowScene?.delegate as? SceneDelegate
                sceneDelegate?.window?.rootViewController = UINavigationController(rootViewController: PostBoardViewController())
                sceneDelegate?.window?.makeKeyAndVisible()
            } onError: { owner, error in
                print("오류 발생")
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
                }
            }
        }
        picker.dismiss(animated: true)
    }
}
