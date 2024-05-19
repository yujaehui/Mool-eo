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
        
        let postBoardVC = UINavigationController(rootViewController: PostListViewController())
        postBoardVC.tabBarItem = UITabBarItem(title: "게시판", image: UIImage(systemName: "list.clipboard"), selectedImage: UIImage(systemName: "list.clipboard"))
        
        let likeListVC = UINavigationController(rootViewController: LikeListViewController())
        likeListVC.tabBarItem = UITabBarItem(title: "좋아요", image: UIImage(systemName: "heart"), selectedImage: UIImage(systemName: "heart"))
        
        let chatVC = UINavigationController(rootViewController: ChatListViewController())
        chatVC.tabBarItem = UITabBarItem(title: "채팅", image: UIImage(systemName: "message"), selectedImage: UIImage(systemName: "message"))
        
        let profileVC = UINavigationController(rootViewController: MyViewController())
        profileVC.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person"))
        
        self.viewControllers = [productPostListVC, postBoardVC, likeListVC, chatVC, profileVC]
    }
}

