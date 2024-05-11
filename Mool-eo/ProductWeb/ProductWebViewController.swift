//
//  ProductWebViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/11/24.
//

import UIKit
import SnapKit
import iamport_ios
import RxSwift
import RxCocoa

class ProductWebViewController: BaseViewController {
    
    //let viewModel = ProductWebViewModel()
    let productWebView = ProductWebView()

    var payment: IamportPayment = IamportPayment(pg: "", merchant_uid: "", amount: "")
    
    override func loadView() {
        self.view = productWebView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Iamport.shared.paymentWebView(
            webViewMode: self.productWebView.wkWebView,
            userCode: "imp57573124",
            payment: payment) { iamportResponse in
                print(String(describing: iamportResponse))
            }
    }
}
