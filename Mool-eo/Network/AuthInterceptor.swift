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
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 419 || // accessToken 만료
              response.statusCode == 418 // refreshToken 만료
        else {
            // 토큰 만료와 관련된 에러가 아닌 경우에는 관련 에러를 반환하고, 재시도는 하지 않음
            completion(.doNotRetryWithError(error))
            return
        }
        
        // 토큰 만료와 관련된 에러의 경우...
        switch response.statusCode {
        case 419:  // accessToken 만료
            print("accessToken 만료: refreshToken으로 교체")
            NetworkManager.shared.refresh()
                .subscribe(with: self) { owner, value in
                    switch value {
                    case .success(let tokenModel):
                        // refreshToken으로 교체 이후 재시도
                        UserDefaultsManager.accessToken = tokenModel.accessToken
                        completion(.retry)
                    case .error(let error):
                        switch error {
                        case .refreshTokenExpired: // refreshToken 만료
                            print("refreshToken 만료: 로그인 화면으로 이동")
                            DispatchQueue.main.async {
                                TransitionManager.shared.setInitialViewController(LoginViewController(), navigation: true)
                            }
                            completion(.doNotRetry) // 로그인 화면으로 이동했기 때문에 재시도 X
                        default: completion(.doNotRetryWithError(error))
                        }
                    }
                }.disposed(by: disposeBag)
        case 418:  // refreshToken 만료
            print("refreshToken 만료: 로그인 화면으로 이동")
            DispatchQueue.main.async {
                TransitionManager.shared.setInitialViewController(LoginViewController(), navigation: true)
            }
            completion(.doNotRetry) // 로그인 화면으로 이동했기 때문에 재시도 X
        default:
            completion(.doNotRetryWithError(error))
        }
    }
}
