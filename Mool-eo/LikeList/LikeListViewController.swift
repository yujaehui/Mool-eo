//
//  LikeListViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/11/24.
//

import UIKit
import Tabman
import Pageboy

class LikeListViewController: TabmanViewController {
    
    let likeProductVC = LikeProductListViewController()
    let likePostVC = LikePostListViewController()
    lazy var viewControllers = [likeProductVC, likePostVC]

    override func viewDidLoad() {
        super.viewDidLoad()
        setNav()
        setButtonBar()
    }
    
    func setNav() {
        navigationItem.title = "좋아요"
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = ColorStyle.point
    }
        
    private func setButtonBar() {
        self.dataSource = self
        let bar = TMBar.ButtonBar()
        bar.tintColor = ColorStyle.point
        bar.backgroundView.style = .clear
        bar.layout.transitionStyle = .snap
        bar.layout.alignment = .centerDistributed
        bar.layout.contentMode = .fit
        addBar(bar, dataSource: self, at: .top)
        
        bar.buttons.customize { (button) in
            button.tintColor = ColorStyle.subText
            button.selectedTintColor = ColorStyle.point
        }
    }
}

extension LikeListViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let item = TMBarItem(title: "")
        switch viewControllers[index] {
        case likeProductVC: item.title = "상품"
        case likePostVC: item.title = "게시글"
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
