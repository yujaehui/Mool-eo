//
//  NetworkManagerProtocol.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/16/24.
//

import RxSwift

protocol NetworkManagerProtocol {
    // User-related functions
    func join(query: JoinQuery) -> Single<NetworkResult<JoinModel>>
    func emailCheck(query: EmailQuery) -> Single<NetworkResult<EmailModel>>
    func login(query: LoginQuery) -> Single<NetworkResult<LoginModel>>
    func withdraw() -> Single<NetworkResult<WithdrawModel>>
    func refresh() -> Single<NetworkResult<TokenModel>>
    
    // Profile-related functions
    func profileCheck() -> Single<NetworkResult<ProfileModel>>
    func profileEdit(query: ProfileEditQuery) -> Single<NetworkResult<ProfileModel>>
    func otherUserProfileCheck(userId: String) -> Single<NetworkResult<OtherUserProfileModel>>
    
    // Post-related functions
    func imageUpload(query: FilesQuery) -> Single<NetworkResult<FilesModel>>
    func postUpload(query: PostQuery) -> Single<NetworkResult<PostModel>>
    func postCheck(productId: String, limit: String, next: String) -> Single<NetworkResult<PostListModel>>
    func postCheckSpecific(postId: String) -> Single<NetworkResult<PostModel>>
    func postCheckUser(userId: String, productId: String, limit: String, next: String) -> Single<NetworkResult<PostListModel>>
    func postDelete(postId: String) -> Single<NetworkResult<Void>>
    func postEdit(query: PostQuery, postId: String) -> Single<NetworkResult<PostModel>>
    
    // Comment-related functions
    func commentUpload(query: CommentQuery, postId: String) -> Single<NetworkResult<CommentModel>>
    func commentDelete(postId: String, commentId: String) -> Single<NetworkResult<Void>>
    
    // LikeProduct-related functions
    func likeProductUpload(query: LikeProductQuery, postId: String) -> Single<NetworkResult<LikeProductModel>>
    func likeProdcutCheck(limit: String, next: String) -> Single<NetworkResult<PostListModel>>
    
    // LikePost-related functions
    func likePostUpload(query: LikePostQuery, postId: String) -> Single<NetworkResult<LikePostModel>>
    func likePostCheck(limit: String, next: String) -> Single<NetworkResult<PostListModel>>
    
    // Follow-related functions
    func follow(userId: String) -> Single<NetworkResult<FollowModel>>
    func unfollow(userId: String) -> Single<NetworkResult<FollowModel>>
    
    // Payment-related functions
    func paymentValidation(query: PaymentQuery) -> Single<NetworkResult<Void>>
    func paymentCheck() -> Single<NetworkResult<PaymentListModel>>
    
    // Hashtag-related functions
    func hashtag(hashtag: String, productId: String, limit: String, next: String) -> Single<NetworkResult<PostListModel>>
    
    // Chat-related functions
    func chatProduce(query: ChatProduceQuery) -> Single<NetworkResult<ChatRoomModel>>
    func chatListCheck() -> Single<NetworkResult<ChatListModel>>
    func chatHistoryCheck(roomId: String, cursorDate: String) -> Single<NetworkResult<ChatHistoryModel>>
    func chatImageUpload(query: FilesQuery, roomId: String) -> Single<NetworkResult<FilesModel>>
    func chatSend(query: ChatSendQuery, roomId: String) -> Single<NetworkResult<Chat>>
}
