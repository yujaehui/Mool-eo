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

enum NetworkResult<T> {
    case success(T)
    case error(NetworkError)
}

enum NetworkError: Int, Error {
    case badRequest = 400
    case authenticationErr = 401
    case forbidden = 403
    case conflict = 409
    case notFoundErr = 410
    case unauthorized = 445
    case refreshTokenExpired = 418
    
    case missingKey = 420
    case overRequestLimit = 429
    case invalidURL = 444
    case serverError = 500
    
    case networkFail
}

struct NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private func performRequest<T: Decodable, U: TargetType>(target: U) -> Single<NetworkResult<T>> where U: TargetType {
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
                        single(.success(.error(NetworkError.networkFail)))
                    }
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    private func performVoidRequest<U: TargetType>(target: U) -> Single<NetworkResult<Void>> {
        return Single.create { single in
            let provider = MoyaProvider<U>(session: Moya.Session(interceptor: AuthInterceptor.shared), plugins: [NetworkLoggerPlugin()])
            let request = provider.request(target) { result in
                switch result {
                case .success:
                    single(.success(.success(())))
                case .failure(let error):
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
        return performRequest(target: UserService.join(query: query))
    }
    
    func emailCheck(query: EmailQuery) -> Single<NetworkResult<EmailModel>> {
        return performRequest(target: UserService.email(query: query))
    }
    
    func login(query: LoginQuery) -> Single<NetworkResult<LoginModel>> {
        return performRequest(target: UserService.login(query: query))
    }
    
    func withdraw() -> Single<NetworkResult<WithdrawModel>> {
        return performRequest(target: UserService.withdraw)
    }
    
    func refresh() -> Single<NetworkResult<TokenModel>> {
        return performRequest(target: UserService.refresh)
    }
    
    //MARK: - Profile
    func profileCheck() -> Single<NetworkResult<ProfileModel>> {
        return performRequest(target: ProfileService.profileCheck)
    }
    
    func profileEdit(query: ProfileEditQuery) -> Single<NetworkResult<ProfileModel>> {
        return performRequest(target: ProfileService.profileEdit(query: query))
    }
    
    func otherUserProfileCheck(userId: String) -> Single<NetworkResult<OtherUserProfileModel>> {
        return performRequest(target: ProfileService.otherUserProfileCheck(userId: userId))
    }
    
    // MARK: - Post
    func imageUpload(query: FilesQuery) -> Single<NetworkResult<FilesModel>> {
        return performRequest(target: PostService.imageUpload(query: query))
    }
    
    func postUpload(query: PostQuery) -> Single<NetworkResult<PostModel>> {
        return performRequest(target: PostService.postUpload(query: query))
    }
    
    func postCheck(productId: String, limit: String, next: String) -> Single<NetworkResult<PostListModel>> {
        return performRequest(target: PostService.postCheck(productId: productId, limit: limit, next: next))
    }
    
    func postCheckSpecific(postId: String) -> Single<NetworkResult<PostModel>> {
        return performRequest(target: PostService.postCheckSpecific(postId: postId))
    }
    
    func postCheckUser(userId: String, productId: String, limit: String, next: String) -> Single<NetworkResult<PostListModel>> {
        return performRequest(target: PostService.postCheckUser(userId: userId, productId: productId, limit: limit, next: next))
    }
    
    func postDelete(postId: String) -> Single<NetworkResult<Void>> {
        return performVoidRequest(target: PostService.postDelete(postID: postId))
    }
    
    func postEdit(query: PostQuery, postId: String) -> Single<NetworkResult<PostModel>> {
        return performRequest(target: PostService.postEdit(query: query, postId: postId))
    }
    
    // MARK: - Comment
    func commentUpload(query: CommentQuery, postId: String) -> Single<NetworkResult<CommentModel>> {
        return performRequest(target: CommentService.commentUpload(query: query, postId: postId))
    }
    
    func commentDelete(postId: String, commentId: String) -> Single<NetworkResult<Void>> {
        return performVoidRequest(target: CommentService.commentDelete(postId: postId, commentId: commentId))
    }
    
    //MARK: - LikeProduct
    func likeProductUpload(query: LikeProductQuery, postId: String) -> Single<NetworkResult<LikeProductModel>> {
        return performRequest(target: LikeProductService.likeProductUpload(query: query, postId: postId))
    }
    
    func likeProdcutCheck(limit: String, next: String) -> Single<NetworkResult<PostListModel>> {
        return performRequest(target: LikeProductService.likeProdcutCheck(limit: limit, next: next))
    }
    
    //MARK: - LikePost
    func likePostUpload(query: LikePostQuery, postId: String) -> Single<NetworkResult<LikePostModel>> {
        return performRequest(target: LikePostService.likePostUpload(query: query, postId: postId))
    }
    
    func likePostCheck(limit: String, next: String) -> Single<NetworkResult<PostListModel>> {
        return performRequest(target: LikePostService.likePostCheck(limit: limit, next: next))
    }
    
    //MARK: - Follow
    func follow(userId: String) -> Single<NetworkResult<FollowModel>> {
        return performRequest(target: FollowService.follow(userId: userId))
    }
    
    func unfollow(userId: String) -> Single<NetworkResult<FollowModel>> {
        return performRequest(target: FollowService.unfollow(userId: userId))
    }
    
    //MARK: - Payment
    func paymentValidation(query: PaymentQuery) -> Single<NetworkResult<Void>> {
        return performVoidRequest(target: PaymentService.paymentValidation(query: query))
    }
    
    func paymentCheck() -> Single<NetworkResult<PaymentListModel>> {
        return performRequest(target: PaymentService.paymentCheck)
    }
    
    //MARK: - Hashtag
    func hashtag(hashtag: String, productId: String, limit: String, next: String) -> Single<NetworkResult<PostListModel>> {
        return performRequest(target: HashtagService.hashtag(hashtag: hashtag, productId: productId, limit: limit, next: next))
    }
    
    //MARK: - Chat
    func chatProduce(query: ChatProduceQuery) -> Single<NetworkResult<ChatRoomModel>> {
        return performRequest(target: ChatService.chatProduce(query: query))
    }
    
    func chatListCheck() -> Single<NetworkResult<ChatListModel>> {
        return performRequest(target: ChatService.chatListCheck)
    }
    
    func chatHistoryCheck(roomId: String, cursorDate: String) -> Single<NetworkResult<ChatHistoryModel>> {
        return performRequest(target: ChatService.chatHistoryCheck(roomId: roomId, cursorDate: cursorDate))
    }
    
    func chatImageUpload(query: FilesQuery, roomId: String) -> Single<NetworkResult<FilesModel>> {
        return performRequest(target: ChatService.chatImageUpload(query: query, roomId: roomId))
    }
    
    func chatSend(query: ChatSendQuery, roomId: String) -> Single<NetworkResult<Chat>> {
        return performRequest(target: ChatService.chatSend(query: query, roomId: roomId))
    }
}
