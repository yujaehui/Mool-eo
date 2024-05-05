//
//  UserDefaultsManager.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/3/24.
//

import Foundation

@propertyWrapper
struct MyDefaults<T> {
    
    let key: String
    let defaultsValue: T
    
    var wrappedValue: T? {
        get { UserDefaults.standard.object(forKey: key) as? T }
        set { UserDefaults.standard.setValue(newValue, forKey: key) }
    }
}

enum UserDefaultsManager {
    enum Key: String {
        case userId
        case accessToken
        case refreshToken
    }
    
    @MyDefaults(key: Key.userId.rawValue, defaultsValue: "") static var userId
    @MyDefaults(key: Key.accessToken.rawValue, defaultsValue: "") static var accessToken
    @MyDefaults(key: Key.refreshToken.rawValue, defaultsValue: "") static var refreshToken
}
