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
        let postBoardVC = UINavigationController(rootViewController: PostBoardViewController())
        postBoardVC.tabBarItem = UITabBarItem(title: "게시판", image: UIImage(systemName: "list.clipboard"), selectedImage: UIImage(systemName: "list.clipboard"))
        
        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person"))
        
        self.viewControllers = [postBoardVC, profileVC]
    }
}

