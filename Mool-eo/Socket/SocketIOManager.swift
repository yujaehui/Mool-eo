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
    static let shared = SocketIOManager(roomID: "")
    
    var manager: SocketManager!
    var socket: SocketIOClient!
    let baseURL = URL(string: APIKey.baseURL.rawValue)!
    var receivedChatData = PublishSubject<ChatModel>()
    
    
    private init(roomID: String) {
        print("SOCKETIOMANAGER INIT")
        
        manager = SocketManager(socketURL: baseURL, config: [.log(true), .compress])
        socket = manager.socket(forNamespace: roomID)
        
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
    
    func establishConnection() {
        socket.connect()
    }
    
    func leaveConnection() {
        socket.disconnect()
    }
}
