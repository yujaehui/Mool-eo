//
//  NetworkManager.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/14/24.
//

import Foundation
import Alamofire
import RxSwift
import Moya
import RxMoya

enum NetworkResult<T: Decodable> {
    case success(T)
    case error(NetworkError)
}

enum NetworkError: Int, Error {
    case AuthenticationErr = 401
    case missingKey = 420
    case overRequestLimit = 429
    case invalidURL = 444
    case serverError = 500
    case badRequest = 400
    case conflict = 409
    case forbidden = 403
    case gone = 410
    case Unauthorized = 445
}

struct NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func requestGeneric<T: Decodable, U: TargetType>(target: U) -> Single<NetworkResult<T>> where U: TargetType {
        return Single.create { single in
            let provider = MoyaProvider<U>(session: Moya.Session(interceptor: AuthInterceptor.shared), plugins: [NetworkLoggerPlugin()])
            let request = provider.request(target) { result in
                switch result {
                case let .success(response):
                    do {
                        let returnObject = try response.map(T.self)
                        single(.success(.success(returnObject)))
                    } catch {
                        single(.failure(error))
                    }
                    
                case let .failure(error):
                    if let statusCode = error.response?.statusCode {
                        if let networkError = NetworkError(rawValue: statusCode) {
                            single(.success(.error(networkError)))
                        }
                    } else {
                        single(.failure(error))
                    }
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    //MARK: - User
    func join(query: JoinQuery) -> Single<NetworkResult<JoinModel>> {
        return requestGeneric(target: UserService.join(query: query))
    }
    
    func emailCheck(query: EmailQuery) -> Single<NetworkResult<EmailModel>> {
        return requestGeneric(target: UserService.email(query: query))
    }
    
    func login(query: LoginQuery) -> Single<NetworkResult<LoginModel>> {
        return requestGeneric(target: UserService.login(query: query))
    }
    
    func withdraw() -> Single<NetworkResult<WithdrawModel>> {
        return requestGeneric(target: UserService.withdraw)
    }
    
    func refresh() -> Single<NetworkResult<TokenModel>> {
        return requestGeneric(target: UserService.refresh)
    }
    
    //MARK: - Profile
    func profileCheck() -> Single<NetworkResult<ProfileModel>> {
        return requestGeneric(target: ProfileService.profileCheck)
    }
    
    func profileEdit(query: ProfileEditQuery) -> Single<NetworkResult<ProfileModel>> {
        return requestGeneric(target: ProfileService.profileEdit(query: query))
    }
    
    func otherUserProfileCheck(userId: String) -> Single<NetworkResult<OtherUserProfileModel>> {
        return requestGeneric(target: ProfileService.otherUserProfileCheck(userId: userId))
    }
    
    // MARK: - Post
    func imageUpload(query: FilesQuery) -> Single<NetworkResult<FilesModel>> {
        return requestGeneric(target: PostService.imageUpload(query: query))
    }
    
    func postUpload(query: PostQuery) -> Single<NetworkResult<PostModel>> {
        return requestGeneric(target: PostService.postUpload(query: query))
    }
    
    func postCheck(productId: String) -> Single<NetworkResult<PostListModel>> {
        return requestGeneric(target: PostService.postCheck(productId: productId))
    }
    
    func postCheckSpecific(postId: String) -> Single<NetworkResult<PostModel>> {
        return requestGeneric(target: PostService.postCheckSpecific(postId: postId))
    }
    
    func postCheckUser(userId: String) -> Single<NetworkResult<PostListModel>> {
        return requestGeneric(target: PostService.postCheckUser(userId: userId))
    }
    
    func postDelete(postId: String) -> Single<NetworkResult<Empty>> {
        return requestGeneric(target: PostService.postDelete(postID: postId))
    }
    
    func postEdit(query: PostQuery, postId: String) -> Single<NetworkResult<PostModel>> {
        return requestGeneric(target: PostService.postEdit(query: query, postId: postId))
    }
    
    // MARK: - Comment
    func commentUpload(query: CommentQuery, postId: String) -> Single<NetworkResult<CommentModel>> {
        return requestGeneric(target: CommentService.commentUpload(query: query, postId: postId))
    }
    
    func commentDelete(postId: String, commentId: String) -> Single<NetworkResult<Empty>> {
        return requestGeneric(target: CommentService.commentDelete(postId: postId, commentId: commentId))
    }
    
    //MARK: - Like    
    func likeUpload(query: LikeQuery, postId: String) -> Single<NetworkResult<LikeModel>> {
        return requestGeneric(target: LikeService.likeUpload(query: query, postId: postId))
    }
    
    //MARK: - Scrap
    func scrapUpload(query: ScrapQuery, postId: String) -> Single<NetworkResult<ScrapModel>> {
        return requestGeneric(target: ScrapService.scrapUpload(query: query, postId: postId))
    }
    
    func scrapPostCheck() -> Single<NetworkResult<PostListModel>> {
        return requestGeneric(target: ScrapService.scrapPostCheck)
    }
    
    //MARK: - Follow
    func follow(userId: String) -> Single<NetworkResult<FollowModel>> {
        return requestGeneric(target: FollowService.follow(userId: userId))
    }
    
    func unfollow(userId: String) -> Single<NetworkResult<FollowModel>> {
        return requestGeneric(target: FollowService.unfollow(userId: userId))
    }
}
