//
//  TransitionManager.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/7/24.
//

import UIKit

final class TransitionManager {
    static let shared = TransitionManager()
    private init() {}
    
    func setInitialViewController(_ rootViewController: UIViewController, navigation: Bool) {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let sceneDelegate = windowScene?.delegate as? SceneDelegate
        sceneDelegate?.window?.rootViewController = navigation ? rootViewController : UINavigationController(rootViewController: rootViewController)
        sceneDelegate?.window?.makeKeyAndVisible()
    }
}
