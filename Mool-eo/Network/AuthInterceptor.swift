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

final class AuthInterceptor: RequestInterceptor {
    
    static let shared = AuthInterceptor()
    private init() {}
    
    let disposeBag = DisposeBag()
    
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
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        switch response.statusCode {
        case 419:
            handleAccessTokenExpiry(completion: completion)
        case 418:
            handleRefreshTokenExpiry(completion: completion)
        default:
            completion(.doNotRetryWithError(error))
        }
    }
    
    private func handleAccessTokenExpiry(completion: @escaping (RetryResult) -> Void) {
        NetworkManager.shared.refresh()
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let tokenModel):
                    UserDefaultsManager.accessToken = tokenModel.accessToken
                    completion(.retry)
                case .error(let error):
                    owner.handleTokenRefreshError(error, completion: completion)
                }
            }.disposed(by: disposeBag)
    }
    
    private func handleRefreshTokenExpiry(completion: @escaping (RetryResult) -> Void) {
        DispatchQueue.main.async {
            TransitionManager.shared.setInitialViewController(LoginViewController(), navigation: true)
        }
        completion(.doNotRetry)
    }
    
    private func handleTokenRefreshError(_ error: NetworkError, completion: @escaping (RetryResult) -> Void) {
        switch error {
        case .refreshTokenExpired:
            DispatchQueue.main.async {
                TransitionManager.shared.setInitialViewController(LoginViewController(), navigation: true)
            }
            completion(.doNotRetry)
        default:
            completion(.doNotRetryWithError(error))
        }
    }
}

