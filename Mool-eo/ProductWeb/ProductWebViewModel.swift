//
//  ProductWebViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/11/24.
//

import Foundation
import RxSwift
import RxCocoa
import iamport_ios

class ProductWebViewModel: ViewModelType {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let postModel: Observable<PostModel?>
        let iamportResponseSubject: PublishSubject<IamportResponse?>
    }
    
    struct Output {
        let postModel: Observable<PostModel?>
        let paymentValidationSuccessTrigger: PublishSubject<Void>
    }
    
    func transform(input: Input) -> Output {
        let paymentValidationSuccessTrigger = PublishSubject<Void>()
        
        let paymentObsevable = Observable.combineLatest(input.postModel, input.iamportResponseSubject)
        
        paymentObsevable
            .map { (postModel, response) in
                guard let postModel = postModel,
                      let response = response,
                      let imp_uid = response.imp_uid,
                      let price = postModel.content1.toInt()
                else { return nil }
                return PaymentQuery(imp_uid: imp_uid, post_id: postModel.postId, productName: postModel.title, price: price)
            }
            .compactMap { $0 }
            .flatMap { query in
                NetworkManager.shared.paymentValidation(query: query)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(_): paymentValidationSuccessTrigger.onNext(())
                case .error(let error): print(error)
                }
            }.disposed(by: disposeBag)
        
        return Output(postModel: input.postModel, paymentValidationSuccessTrigger: paymentValidationSuccessTrigger)
    }
}
