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

struct NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    
    //MARK: - User
    private let userProvider = MoyaProvider<UserService>(plugins: [NetworkLoggerPlugin()])
    
    func join(query: JoinQuery) -> Single<JoinModel> {
        return userProvider.rx.request(.join(query: query)).map(JoinModel.self)
    }
    
    func emailCheck(query: EmailQuery) -> Single<EmailModel> {
        return userProvider.rx.request(.email(query: query)).map(EmailModel.self)
    }
    
    func login(query: LoginQuery) -> Single<LoginModel> {
        return userProvider.rx.request(.login(query: query))
            .map(LoginModel.self)
            .do(onSuccess: { response in
                UserDefaultsManager.userId = response.user_id
                UserDefaultsManager.accessToken = response.accessToken
                UserDefaultsManager.refreshToken = response.refreshToken
            })
    }
    
    func withdraw() -> Single<WithdrawModel> {
        return userProvider.rx.request(.withdraw).map(WithdrawModel.self)
    }
    
    func refresh() -> Single<TokenModel> {
        return userProvider.rx.request(.refresh).map(TokenModel.self)
    }
    
    // MARK: - Post
    private let postProvider = MoyaProvider<PostService>(session: Moya.Session(interceptor: AuthInterceptor.shared), plugins: [NetworkLoggerPlugin()])
    
    func imageUpload(query: FilesQuery) -> Single<FilesModel> {
        return postProvider.rx.request(.imageUpload(query: query)).map(FilesModel.self)
    }
    
    func postUpload(query: PostQuery) -> Single<PostModel> {
        return postProvider.rx.request(.postUpload(query: query)).map(PostModel.self)
    }
    
    func postCheck(productId: String) -> Single<PostListModel> {
        return postProvider.rx.request(.postCheck(productId: productId)).map(PostListModel.self)
    }
    
    func postCheckSpecific(postId: String) -> Single<PostModel> {
        return postProvider.rx.request(.postCheckSpecific(postId: postId)).map(PostModel.self)
    }
    
    func postCheckUser(userId: String) -> Single<PostListModel> {
        return postProvider.rx.request(.postCheckUser(userId: userId)).map(PostListModel.self)
    }
    
    func postDelete(postId: String) -> Single<Response> {
        return postProvider.rx.request(.postDelete(postID: postId))
    }
    
    func postEdit(query: PostQuery, postId: String) -> Single<PostModel> {
        return postProvider.rx.request(.postEdit(query: query, postId: postId)).map(PostModel.self)
    }
    
    // MARK: - Comment

    private let commentProvider = MoyaProvider<CommentService>(session: Moya.Session(interceptor: AuthInterceptor.shared), plugins: [NetworkLoggerPlugin()])
    
    func commentUpload(query: CommentQuery, postId: String) -> Single<CommentModel> {
        return commentProvider.rx.request(.uploadComment(query: query, postId: postId)).map(CommentModel.self)
    }
    
    func commentDelete(postId: String, commentId: String) -> Single<Response> {
        return commentProvider.rx.request(.commentDelete(postId: postId, commentId: commentId))
    }
    
    //MARK: - Profile
    private let profileProvider = MoyaProvider<ProfileService>(session: Moya.Session(interceptor: AuthInterceptor.shared), plugins: [NetworkLoggerPlugin()])
    
    func profileCheck() -> Single<ProfileModel> {
        return profileProvider.rx.request(.profileCheck).map(ProfileModel.self)
    }
    
    func profileEdit(query: ProfileEditQuery) -> Single<ProfileModel> {
        return profileProvider.rx.request(.profileEdit(query: query)).map(ProfileModel.self)
    }
    
    func otherUserProfileCheck(userId: String) -> Single<OtherUserProfileModel> {
        return profileProvider.rx.request(.otherUserProfileCheck(userId: userId)).map(OtherUserProfileModel.self)
    }
    
    //MARK: - Like
    private let likeProvider = MoyaProvider<LikeService>(session: Moya.Session(interceptor: AuthInterceptor.shared), plugins: [NetworkLoggerPlugin()])
    
    func likeUpload(query: LikeQuery, postId: String) -> Single<LikeModel> {
        return likeProvider.rx.request(.likeUpload(query: query, postId: postId)).map(LikeModel.self)
    }
    
    //MARK: - Scrap
    private let scrapProvider = MoyaProvider<ScrapService>(session: Moya.Session(interceptor: AuthInterceptor.shared), plugins: [NetworkLoggerPlugin()])
    
    func scrapUpload(query: ScrapQuery, postId: String) -> Single<ScrapModel> {
        return scrapProvider.rx.request(.scrapUpload(query: query, postId: postId)).map(ScrapModel.self)
    }
    
    func scrapPostCheck() -> Single<PostListModel> {
        return scrapProvider.rx.request(.scrapPostCheck).map(PostListModel.self)
    }
    
    //MARK: - Follow
    private let followProvider = MoyaProvider<FollowService>(session: Moya.Session(interceptor: AuthInterceptor.shared), plugins: [NetworkLoggerPlugin()])
    
    func follow(userId: String) -> Single<FollowModel> {
        return followProvider.rx.request(.follow(userId: userId)).map(FollowModel.self)
    }
    
    func unfollow(userId: String) -> Single<FollowModel> {
        return followProvider.rx.request(.unfollow(userId: userId)).map(FollowModel.self)
    }
}
