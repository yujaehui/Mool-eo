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
    
    private func provider<U: TargetType>() -> MoyaProvider<U> {
        return MoyaProvider<U>(
            session: Moya.Session(interceptor: AuthInterceptor.shared),
            plugins: [NetworkLoggerPlugin()]
        )
    }
    
    private func mapNetworkError(_ error: MoyaError) -> NetworkError {
        if let statusCode = error.response?.statusCode,
           let networkError = NetworkError(rawValue: statusCode) {
            return networkError
        }
        return .networkFail
    }
    
    private func createSingle<U: TargetType, T>(target: U, mapResponse: @escaping (Response) throws -> T) -> Single<NetworkResult<T>> {
        return Single.create { single in
            let request = provider().request(target) { result in
                switch result {
                case let .success(response):
                    do {
                        let returnObject = try mapResponse(response)
                        single(.success(.success(returnObject)))
                    } catch {
                        single(.failure(error))
                    }
                    
                case let .failure(error):
                    single(.success(.error(mapNetworkError(error))))
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    private func performDecodableRequest<T: Decodable, U: TargetType>(target: U) -> Single<NetworkResult<T>> where U: TargetType {
        return createSingle(target: target) { response in
            return try response.map(T.self)
        }
    }
    
    private func performSimpleRequest<U: TargetType>(target: U) -> Single<NetworkResult<Void>> {
        return createSingle(target: target) { _ in
            return ()
        }
    }
    
    //MARK: - User
    func join(query: JoinQuery) -> Single<NetworkResult<JoinModel>> {
        return performDecodableRequest(target: UserService.join(query: query))
    }
    
    func emailCheck(query: EmailQuery) -> Single<NetworkResult<EmailModel>> {
        return performDecodableRequest(target: UserService.email(query: query))
    }
    
    func login(query: LoginQuery) -> Single<NetworkResult<LoginModel>> {
        return performDecodableRequest(target: UserService.login(query: query))
    }
    
    func withdraw() -> Single<NetworkResult<WithdrawModel>> {
        return performDecodableRequest(target: UserService.withdraw)
    }
    
    func refresh() -> Single<NetworkResult<TokenModel>> {
        return performDecodableRequest(target: UserService.refresh)
    }
    
    //MARK: - Profile
    func profileCheck() -> Single<NetworkResult<ProfileModel>> {
        return performDecodableRequest(target: ProfileService.profileCheck)
    }
    
    func profileEdit(query: ProfileEditQuery) -> Single<NetworkResult<ProfileModel>> {
        return performDecodableRequest(target: ProfileService.profileEdit(query: query))
    }
    
    func otherUserProfileCheck(userId: String) -> Single<NetworkResult<OtherUserProfileModel>> {
        return performDecodableRequest(target: ProfileService.otherUserProfileCheck(userId: userId))
    }
    
    // MARK: - Post
    func imageUpload(query: FilesQuery) -> Single<NetworkResult<FilesModel>> {
        return performDecodableRequest(target: PostService.imageUpload(query: query))
    }
    
    func postUpload(query: PostQuery) -> Single<NetworkResult<PostModel>> {
        return performDecodableRequest(target: PostService.postUpload(query: query))
    }
    
    func postCheck(productId: String, limit: String, next: String) -> Single<NetworkResult<PostListModel>> {
        return performDecodableRequest(target: PostService.postCheck(productId: productId, limit: limit, next: next))
    }
    
    func postCheckSpecific(postId: String) -> Single<NetworkResult<PostModel>> {
        return performDecodableRequest(target: PostService.postCheckSpecific(postId: postId))
    }
    
    func postCheckUser(userId: String, productId: String, limit: String, next: String) -> Single<NetworkResult<PostListModel>> {
        return performDecodableRequest(target: PostService.postCheckUser(userId: userId, productId: productId, limit: limit, next: next))
    }
    
    func postDelete(postId: String) -> Single<NetworkResult<Void>> {
        return performSimpleRequest(target: PostService.postDelete(postID: postId))
    }
    
    func postEdit(query: PostQuery, postId: String) -> Single<NetworkResult<PostModel>> {
        return performDecodableRequest(target: PostService.postEdit(query: query, postId: postId))
    }
    
    // MARK: - Comment
    func commentUpload(query: CommentQuery, postId: String) -> Single<NetworkResult<CommentModel>> {
        return performDecodableRequest(target: CommentService.commentUpload(query: query, postId: postId))
    }
    
    func commentDelete(postId: String, commentId: String) -> Single<NetworkResult<Void>> {
        return performSimpleRequest(target: CommentService.commentDelete(postId: postId, commentId: commentId))
    }
    
    //MARK: - LikeProduct
    func likeProductUpload(query: LikeProductQuery, postId: String) -> Single<NetworkResult<LikeProductModel>> {
        return performDecodableRequest(target: LikeProductService.likeProductUpload(query: query, postId: postId))
    }
    
    func likeProdcutCheck(limit: String, next: String) -> Single<NetworkResult<PostListModel>> {
        return performDecodableRequest(target: LikeProductService.likeProdcutCheck(limit: limit, next: next))
    }
    
    //MARK: - LikePost
    func likePostUpload(query: LikePostQuery, postId: String) -> Single<NetworkResult<LikePostModel>> {
        return performDecodableRequest(target: LikePostService.likePostUpload(query: query, postId: postId))
    }
    
    func likePostCheck(limit: String, next: String) -> Single<NetworkResult<PostListModel>> {
        return performDecodableRequest(target: LikePostService.likePostCheck(limit: limit, next: next))
    }
    
    //MARK: - Follow
    func follow(userId: String) -> Single<NetworkResult<FollowModel>> {
        return performDecodableRequest(target: FollowService.follow(userId: userId))
    }
    
    func unfollow(userId: String) -> Single<NetworkResult<FollowModel>> {
        return performDecodableRequest(target: FollowService.unfollow(userId: userId))
    }
    
    //MARK: - Payment
    func paymentValidation(query: PaymentQuery) -> Single<NetworkResult<Void>> {
        return performSimpleRequest(target: PaymentService.paymentValidation(query: query))
    }
    
    func paymentCheck() -> Single<NetworkResult<PaymentListModel>> {
        return performDecodableRequest(target: PaymentService.paymentCheck)
    }
    
    //MARK: - Hashtag
    func hashtag(hashtag: String, productId: String, limit: String, next: String) -> Single<NetworkResult<PostListModel>> {
        return performDecodableRequest(target: HashtagService.hashtag(hashtag: hashtag, productId: productId, limit: limit, next: next))
    }
    
    //MARK: - Chat
    func chatProduce(query: ChatProduceQuery) -> Single<NetworkResult<ChatRoomModel>> {
        return performDecodableRequest(target: ChatService.chatProduce(query: query))
    }
    
    func chatListCheck() -> Single<NetworkResult<ChatListModel>> {
        return performDecodableRequest(target: ChatService.chatListCheck)
    }
    
    func chatHistoryCheck(roomId: String, cursorDate: String) -> Single<NetworkResult<ChatHistoryModel>> {
        return performDecodableRequest(target: ChatService.chatHistoryCheck(roomId: roomId, cursorDate: cursorDate))
    }
    
    func chatImageUpload(query: FilesQuery, roomId: String) -> Single<NetworkResult<FilesModel>> {
        return performDecodableRequest(target: ChatService.chatImageUpload(query: query, roomId: roomId))
    }
    
    func chatSend(query: ChatSendQuery, roomId: String) -> Single<NetworkResult<Chat>> {
        return performDecodableRequest(target: ChatService.chatSend(query: query, roomId: roomId))
    }
}
