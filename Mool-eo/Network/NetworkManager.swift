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
                UserDefaults.standard.set(response.user_id, forKey: "userId")
                UserDefaults.standard.set(response.accessToken, forKey: "accessToken")
                UserDefaults.standard.set(response.refreshToken, forKey: "refreshToken")
            })
    }
    
    func withdraw() -> Single<WithdrawModel> {
        return userProvider.rx.request(.withdraw).map(WithdrawModel.self)
    }
    
    func refresh() -> Single<TokenModel> {
        return userProvider.rx.request(.refresh).map(TokenModel.self)
    }
    
    // MARK: - Post
    private let postProvider = MoyaProvider<PostService>(plugins: [NetworkLoggerPlugin()])
    
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
    
    func postCheckUser() -> Single<PostListModel> {
        let userId = UserDefaults.standard.string(forKey: "userId")!
        return postProvider.rx.request(.postCheckUser(userId: userId)).map(PostListModel.self)
    }
    
    // MARK: - Comment

    private let commentProvider = MoyaProvider<CommentService>(plugins: [NetworkLoggerPlugin()])
    
    func commentUpload(query: CommentQuery, postId: String) -> Single<CommentModel> {
        return commentProvider.rx.request(.uploadComment(query: query, postId: postId)).map(CommentModel.self)
    }
    
    //MARK: - Profile
    private let profileProvider = MoyaProvider<ProfileService>(plugins: [NetworkLoggerPlugin()])
    
    func profileCheck() -> Single<ProfileModel> {
        return profileProvider.rx.request(.profileCheck).map(ProfileModel.self)
    }
    
    func profileEdit(query: ProfileEditQuery) -> Single<ProfileModel> {
        return profileProvider.rx.request(.profileEdit(query: query)).map(ProfileModel.self)
    }
    
    //MARK: - Like
    private let likeProvider = MoyaProvider<LikeService>(plugins: [NetworkLoggerPlugin()])
    
    func likeUpload(query: LikeQuery, postId: String) -> Single<LikeModel> {
        return likeProvider.rx.request(.likeUpload(query: query, postId: postId)).map(LikeModel.self)
    }
    
    //MARK: - Scrap
    private let scrapProvider = MoyaProvider<ScrapService>(plugins: [NetworkLoggerPlugin()])
    
    func scrapUpload(query: ScrapQuery, postId: String) -> Single<ScrapModel> {
        return scrapProvider.rx.request(.scrapUpload(query: query, postId: postId)).map(ScrapModel.self)
    }
}
