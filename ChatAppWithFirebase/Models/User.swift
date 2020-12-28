//
//  User.swift
//  ChatAppWithFirebase
//
//  Created by Tetsuya Kamijo on 2020/12/15.
//  Copyright © 2020 Tetsuya Kamijo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class User {
    let email: String
    let username: String
    let createdAt: Timestamp
    let profileImageURL: String
    
    var uid: String?
    
    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.createdAt = dic["createAt"] as? Timestamp ?? Timestamp()
        self.profileImageURL = dic["profileImageURL"] as? String ?? ""
    }
    
}
