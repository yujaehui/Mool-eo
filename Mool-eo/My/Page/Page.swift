//
//  Page.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/27/24.
//

import UIKit

struct Page {
    var name = ""
    var vc = UIViewController()
    
    init(with _name: String, _vc: UIViewController) {
        name = _name
        vc = _vc
    }
}
