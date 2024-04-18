//
//  ProfileEditViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/18/24.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileEditViewController: BaseViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = ProfileEditViewModel()
    let profileEditView = ProfileEditView()
    
    override func loadView() {
        self.view = profileEditView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
