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
                        print(response.response?.statusCode)
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
    
    static func profileEdit(query: ProfileEditQuery) -> Single<ProfileModel> {
        return Single<ProfileModel>.create { single in
            let url = URL(string: APIKey.baseURL.rawValue + "/users/me/profile")!
            let headers: HTTPHeaders = [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
                                        HTTPHeader.contentType.rawValue : HTTPHeader.multipart.rawValue,
                                        HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
            let parameters: [String : Any] = ["nick": query.nick,
                                              "birthDay": query.birthDay]
            AF.upload(multipartFormData: { multipartFormData in
                for (key, value) in parameters {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                }
                multipartFormData.append(query.profile, withName: "profile", fileName: "image.png", mimeType: "image/png")
            }, to: url, method: .put, headers: headers)
            .responseDecodable(of: ProfileModel.self) { response in
                switch response.result {
                case .success(let success):
                    single(.success(success))
                case .failure(let failure):
                    single(.failure(failure))
                }
            }
            return Disposables.create()
        }
    }
    
    // MARK: - Post
    static func imageUpload(query: FilesQuery) -> Single<FilesModel> {
        return Single<FilesModel>.create { single in
            let url = URL(string: APIKey.baseURL.rawValue + "posts/files")!
            let headers: HTTPHeaders = [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
                                        HTTPHeader.contentType.rawValue : HTTPHeader.multipart.rawValue,
                                        HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
            AF.upload(multipartFormData: { multipartFormData in
                for (index, fileData) in query.files.enumerated() {
                    multipartFormData.append(fileData, withName: "files", fileName: "image\(index).png", mimeType: "image/png")
                }
            }, to: url, headers: headers)
            .responseDecodable(of: FilesModel.self) { response in
                switch response.result {
                case .success(let success):
                    single(.success(success))
                case .failure(let failure):
                    print("...", response.response?.statusCode)
                    single(.failure(failure))
                }
            }
            return Disposables.create()
        }
    }
    
    static func postUpload(query: PostQuery) -> Single<PostModel> {
        do {
            let urlRequest = try PostRouter.postUpload(query: query).asURLRequest()
            return request(route: urlRequest, interceptor: nil) { _ in }
        } catch {
            return Single.error(error)
        }
    }
    
    static func postCheck(productId: String) -> Single<PostListModel> {
        do {
            let urlRequest = try PostRouter.postCheck(productId: productId).asURLRequest()
            return request(route: urlRequest, interceptor: nil) { _ in }
        } catch {
            return Single.error(error)
        }
    }
}
