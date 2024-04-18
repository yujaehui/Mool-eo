//
//  NetworkManager.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/14/24.
//

import Foundation
import Alamofire
import RxSwift

struct NetworkManager {
    static func request<T: Decodable>(route: URLRequestConvertible, interceptor: RequestInterceptor?, onSuccess: @escaping (T) -> Void) -> Single<T> {
        return Single<T>.create { single in
            AF.request(route, interceptor: interceptor)
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let success):
                        onSuccess(success)
                        single(.success(success))
                    case .failure(let failure):
                        single(.failure(failure))
                    }
                }
            return Disposables.create()
        }
    }
    
    //MARK: - User
    static func join(query: JoinQuery) -> Single<JoinModel> {
        do {
            let urlRequest = try UserRouter.join(query: query).asURLRequest()
            return request(route: urlRequest, interceptor: nil) { _ in }
        } catch {
            return Single.error(error)
        }
    }
    
    static func emailCheck(query: EmailQuery) -> Single<EmailModel> {
        do {
            let urlRequest = try UserRouter.email(query: query).asURLRequest()
            return request(route: urlRequest, interceptor: nil) { _ in }
        } catch {
            return Single.error(error)
        }
    }
    
    static func login(query: LoginQuery) -> Single<LoginModel> {
        do {
            let urlRequest = try UserRouter.login(query: query).asURLRequest()
            return request(route: urlRequest, interceptor: nil) { value in
                UserDefaults.standard.set(value.accessToken, forKey: "accessToken")
                UserDefaults.standard.set(value.refreshToken, forKey: "refreshToken")
            }
        } catch {
            return Single.error(error)
        }
    }
    
    static func withdraw() -> Single<WithdrawModel> {
        do {
            let urlRequest = try UserRouter.withdraw.asURLRequest()
            return request(route: urlRequest, interceptor: nil) { _ in }
        } catch {
            return Single.error(error)
        }
    }
    
    static func refresh() -> Single<TokenModel> {
        do {
            let urlRequest = try UserRouter.refresh.asURLRequest()
            return request(route: urlRequest, interceptor: nil) { _ in }
        } catch {
            return Single.error(error)
        }
    }
    
    //MARK: - Profile
    static func profileCheck() -> Single<ProfileModel> {
        do {
            let urlRequest = try ProfileRouter.profileCheck.asURLRequest()
            return request(route: urlRequest, interceptor: AuthInterceptor()) { _ in }
        } catch {
            return Single.error(error)
        }
    }
    
    static func profileEdit() -> Single<ProfileModel> {
        do {
            let urlRequest = try ProfileRouter.profileEdit.asURLRequest()
            return request(route: urlRequest, interceptor: nil) { _ in }
        } catch {
            return Single.error(error)
        }
    }
}
