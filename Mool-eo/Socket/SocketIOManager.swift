//
//  SocketIOManager.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/20/24.
//

import Foundation
import SocketIO
import RxSwift
import RxCocoa

final class SocketIOManager {
    static let shared = SocketIOManager()
    
    var manager: SocketManager!
    var socket: SocketIOClient!
    let baseURL = URL(string: APIKey.baseURL.rawValue)!
    var receivedChatData = PublishSubject<ChatModel>()
    var roomId: String? // 추가: 룸 아이디를 저장할 변수
    
    private init() {
        print("SOCKETIOMANAGER INIT")
        
        manager = SocketManager(socketURL: baseURL, config: [.log(true), .compress])
        socket = manager.socket(forNamespace: "/roomID")
        
        socket.on(clientEvent: .connect) { data, ack in
            print("socket connected")
        }
        
        socket.on(clientEvent: .disconnect) { data, ack in
            print("socket disconnected")
        }
        
        socket.on("chat") { dataArray, ack in
            print("chat received : \(dataArray)")
            
            if let data = dataArray.first {
                let result = try? JSONSerialization.data(withJSONObject: data)
                let decodedData = try? JSONDecoder().decode(ChatModel.self, from: result!)
                self.receivedChatData.onNext(decodedData!)
            }
        }
    }
    
    func establishConnection(_ roomId: String) {
        self.roomId = roomId
        let namespace = "/" + roomId // 룸 아이디 앞에 슬래시 추가
        socket = manager.socket(forNamespace: namespace)
        socket.connect()
    }
    
    func leaveConnection() {
        socket.disconnect()
    }
}
