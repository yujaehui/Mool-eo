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

final class ProductWebViewController: BaseViewController {
    
    let viewModel = ProductWebViewModel()
    let productWebView = ProductWebView()
    
    var postModel: PostModel!
    
    var iamportResponse = PublishSubject<IamportResponse?>()
    
    override func loadView() {
        self.view = productWebView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = ProductWebViewModel.Input(
            postModel: Observable.just(postModel),
            iamportResponse: iamportResponse
        )
        
        let output = viewModel.transform(input: input)
        
        output.postModel.bind(with: self) { owner, postModel in
            let payment = IamportPayment(
                pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
                merchant_uid: "ios_\(APIKey.secretKey)_\(Int(Date().timeIntervalSince1970))",
                amount: self.postModel.content1)
                .then {
                    $0.pay_method = PayMethod.card.rawValue
                    $0.name = self.postModel.title
                    $0.buyer_name = "유재희"
                    $0.app_scheme = "sesac"
                }
            
            Iamport.shared.paymentWebView(
                webViewMode: self.productWebView.wkWebView,
                userCode: "imp57573124",
                payment: payment) { iamportResponse in
                    self.iamportResponse.onNext(iamportResponse)
                }
        }.disposed(by: disposeBag)
        
        output.paymentValidationSuccessTrigger.bind(with: self) { owner, _ in
            NotificationCenter.default.post(name: Notification.Name(Noti.payment.rawValue), object: true)
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
    }
}
