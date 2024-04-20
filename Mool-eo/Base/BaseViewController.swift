//
//  BaseViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorStyle.mainBackground
        configureHierarchy()
        configureView()
        configureConstraints()
        bind()
    }
    
    func configureHierarchy() {}
    func configureView() {}
    func configureConstraints() {}
    func bind() {}
}
