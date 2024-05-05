//
//  AuthInterceptor.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/17/24.
//

import Foundation
import Alamofire
import RxSwift
import UIKit

class AuthInterceptor: RequestInterceptor {
    
    let disposeBag = DisposeBag()
    
    static let shared = AuthInterceptor()
    private init() {}
    
    func adapt(_ urlRequest: URLRequest, for session: Alamofire.Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard urlRequest.url?.absoluteString.hasPrefix(APIKey.baseURL.rawValue) == true,
              let accessToken = UserDefaultsManager.accessToken,
              let refreshToken = UserDefaultsManager.refreshToken
        else {
            completion(.success(urlRequest))
            return
        }
        
        var urlRequest = urlRequest
        urlRequest.setValue(accessToken, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        urlRequest.setValue(refreshToken, forHTTPHeaderField: HTTPHeader.refresh.rawValue)
        completion(.success(urlRequest))
    }
    
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 419  else {
            completion(.doNotRetryWithError(error))
            DispatchQueue.main.async {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let sceneDelegate = windowScene?.delegate as? SceneDelegate
                sceneDelegate?.window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
                sceneDelegate?.window?.makeKeyAndVisible()
            }
            return
        }
        
        Observable.just(())
            .flatMap { _ in
                NetworkManager.shared.refresh()
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let tokenModel):
                    UserDefaultsManager.accessToken = tokenModel.accessToken
                    completion(.retry)
                case .error(let error):
                    completion(.doNotRetryWithError(error))
                }
            } onError: { owner, error in
                completion(.doNotRetryWithError(error))
            }.disposed(by: disposeBag)
    }
}
