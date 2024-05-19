//
//  MyViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import UIKit
import Tabman
import Pageboy

class MyViewController: TabmanViewController {
    
    let likeProductVC = ProfileViewController()
    let likePostVC = ShoppingViewController()
    lazy var viewControllers = [likeProductVC, likePostVC]

    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonBar()
        setNav()
    }
    
    private func setButtonBar() {
        self.dataSource = self
        let bar = TMBar.ButtonBar()
        bar.tintColor = ColorStyle.point
        bar.backgroundView.style = .clear
        bar.layout.transitionStyle = .progressive
        bar.layout.alignment = .centerDistributed
        bar.layout.contentMode = .intrinsic
        addBar(bar, dataSource: self, at: .navigationItem(item: navigationItem))
        
        bar.buttons.customize { (button) in
            button.tintColor = ColorStyle.subText
            button.selectedTintColor = ColorStyle.point
        }
    }
    
    func setNav() {
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = ColorStyle.point
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(rightBarButtonTapped))
    }
    
    @objc private func rightBarButtonTapped() {
        print("Right bar button tapped")
    }
}

extension MyViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let item = TMBarItem(title: "")
        switch viewControllers[index] {
        case likeProductVC: item.title = "내 프로필"
        case likePostVC: item.title = "내 쇼핑"
        default: break
        }
        return item
    }
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }

    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return .at(index: 0)
    }
}
