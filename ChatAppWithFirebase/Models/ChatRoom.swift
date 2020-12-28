//
//  ChatRoom.swift
//  ChatAppWithFirebase
//
//  Created by Tetsuya Kamijo on 2020/12/21.
//  Copyright © 2020 Tetsuya Kamijo. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ChatRoom {
    let latestMessageId: String
    let members: [String]
    let createdAt: Timestamp
    
    var latestMessage: Message?
    var documentId: String?
    var partnerUser: User?
    
    init(dic: [String: Any]) {
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.members = dic["members"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()

    }
    
}
