//
//  UserListViewController.swift
//  ChatAppWithFirebase
//
//  Created by Tetsuya Kamijo on 2020/12/16.
//  Copyright © 2020 Tetsuya Kamijo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import Nuke

class UserListViewController: UIViewController {
    
    private let cellId = "cellId"
    private var users = [User]()
    private var selectedUser: User?
    
    
    @IBOutlet weak var userListTableView: UITableView!
    @IBOutlet weak var startChatButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userListTableView.tableFooterView = UIView()
        
        userListTableView.delegate = self
        userListTableView.dataSource = self
        
        startChatButton.layer.cornerRadius = 15
        startChatButton.isEnabled = false
        startChatButton.addTarget(self, action: #selector(tappedStartChatButton), for: .touchUpInside)
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        
        fetchUserInfoFromFireStore()
        
    }
    
    @objc func tappedStartChatButton() {
        print("tappedStartChatButton")
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let partnerUid = self.selectedUser?.uid else { return }
        let members = [uid, partnerUid]
        
        
        let docData = [
            "members": members,
            "latestMessageId": "",
            "createdAt": Timestamp()
        
            ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").addDocument(data: docData) { (err) in
            if let err = err {
                print("ChatRoom情報の保存が失敗しました")
                return
            }
            
            self.dismiss(animated: true, completion: nil)
            print("chatroom情報の保存に成功しました")
            
        }
        
    }
    
    private func fetchUserInfoFromFireStore() {
        Firestore.firestore().collection("users").getDocuments{ (snapshots, err) in
            if let err = err {
                print("user情報の取得に失敗しました。")
                return
            }
            
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                user.uid = snapshot.documentID
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                if uid == snapshot.documentID {
                    return
                }
                
                self.users.append(user)
                self.userListTableView.reloadData()
                
            })
            
        }
    }
    
}

extension UserListViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserListTableViewCell
        cell.user = users[indexPath.row]
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startChatButton.isEnabled = true
        let user = users[indexPath.row]
        self.selectedUser = user
        
        print("user." , user.username)
        
    }
}

class UserListTableViewCell: UITableViewCell {
    
    var user: User? {
        didSet {
            usernameLabel.text = user?.username
            
            if let url = URL(string: user?.profileImageURL ?? "") {
                Nuke.loadImage(with: url, into: userImageView)
            }
            
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 32.5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
