//
//  BaseViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController {
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorStyle.mainBackground
        configureView()
        bind()
        setNav()
        setToolBar()
    }
    
    func configureView() {}
    func bind() {}
    func setNav() {}
    func setToolBar() {}
}
