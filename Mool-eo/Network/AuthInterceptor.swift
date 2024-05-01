//
//  AuthInterceptor.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/17/24.
//

import Foundation
import Alamofire
import RxSwift

class AuthInterceptor: RequestInterceptor {
    
    let disposeBag = DisposeBag()
    
    func adapt(_ urlRequest: URLRequest, for session: Alamofire.Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            urlRequest.setValue(accessToken, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        }
        completion(.success(urlRequest))
    }

    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print(#function)
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 419 else {
            print("재시도 X")
            completion(.doNotRetry)
            return
        }
        
        NetworkManager.shared.refresh()
            .debug("Refresh")
            .subscribe { event in
                switch event {
                case .success(let success):
                    UserDefaults.standard.set(success.accessToken, forKey: "accessToken")
                    completion(.retry)
                case .failure(let error):
                    completion(.doNotRetryWithError(error))
                }
            }
            .disposed(by: disposeBag)
    }
}
