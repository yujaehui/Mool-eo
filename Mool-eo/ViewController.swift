//
//  ViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import UIKit

class ViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorStyle.mainBackground
        tabBar.tintColor = ColorStyle.point
        addVC()
    }
    
    private func addVC() {
        let productPostListVC = UINavigationController(rootViewController: ProductPostListViewController())
        productPostListVC.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house"))
        
        let postBoardVC = UINavigationController(rootViewController: PostBoardViewController())
        postBoardVC.tabBarItem = UITabBarItem(title: "게시판", image: UIImage(systemName: "list.clipboard"), selectedImage: UIImage(systemName: "list.clipboard"))
        
        let scrapPostListVC = UINavigationController(rootViewController: ScrapPostListViewController())
        scrapPostListVC.tabBarItem = UITabBarItem(title: "스크랩", image: UIImage(systemName: "bookmark"), selectedImage: UIImage(systemName: "bookmark"))
        
        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person"))
        
        self.viewControllers = [productPostListVC, postBoardVC, scrapPostListVC, profileVC]
    }
}

