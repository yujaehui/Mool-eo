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
        bind()
        configureHierarchy()
        configureConstraints()
    }
    
    func bind() {}
    func configureHierarchy() {}
    func configureConstraints() {}
}
