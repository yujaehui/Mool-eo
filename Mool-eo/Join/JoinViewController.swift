//
//  JoinViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import UIKit
import RxSwift

class JoinViewController: BaseViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = JoinViewModel()
    let joinView = JoinView()
    
    override func loadView() {
        self.view = joinView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
    }
}
