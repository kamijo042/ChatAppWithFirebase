//
//  SignUpViewController.swift
//  ChatAppWithFirebase
//
//  Created by Tetsuya Kamijo on 2020/12/13.
//  Copyright © 2020 Tetsuya Kamijo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PKHUD

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // navigationバーを消す
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupViews() {
        profileImageButton.layer.cornerRadius = 85
        profileImageButton.layer.borderWidth = 1
        profileImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        
        registerButton.layer.cornerRadius = 12
        
        profileImageButton.addTarget(self, action: #selector(tappedProfileImageButton), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(tappedRegisterButton), for: .touchUpInside)
        alreadyHaveAccountButton.addTarget(self, action: #selector(tappedAlreadyHaveAccountButton), for: .touchUpInside)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        
        registerButton.isEnabled = false
        registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
    }
    
    @objc private func tappedAlreadyHaveAccountButton() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let LoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        
        self.navigationController?.pushViewController(LoginViewController, animated: true)
    }
    
    @objc private func tappedProfileImageButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @objc private func tappedRegisterButton() {
        // Imageが何も入っていなかったら、デフォルト画像を入れる
        let image = profileImageButton.imageView?.image ?? UIImage(named: "無料の紙飛行機アイコン")
        guard let uploadImage = image?.jpegData(compressionQuality: 0.3) else { return }
        
        HUD.show(.progress)
        
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(filename)
        
        storageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Firebase Storageへの保存に失敗しました。")
                HUD.hide()
                return
            }
            
            storageRef.downloadURL { (url, err) in
                if let err = err {
                    print("ダウンロードに失敗しました")
                    HUD.hide()
                    return
                }
                
                guard let urlString = url?.absoluteString else { return }
                self.createUserToFireStore(profileImageURL: urlString)
            }
        }
    }
    
    private func createUserToFireStore(profileImageURL: String) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("Auth情報の保存に失敗しました")
                HUD.hide()
                return
            }
            
            guard let uid = res?.user.uid else { return }
            guard let username = self.usernameTextField.text else { return }
            
            let docData = [
                "email": email,
                "username": username,
                "createdAt": Timestamp(),
                "profileImageURL": profileImageURL
                ] as [String : Any]
            
            Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
                if let err = err {
                    print("FireStoreの保存に失敗しました")
                    HUD.hide()
                }
                self.dismiss(animated: true, completion: nil)
                
                print("FireStoreの保存に成功しました")
                HUD.hide()
            }
        }
    }
    
    // タッチが始まったら呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        let usernameIsEmpty = usernameTextField.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty {
            registerButton.isEnabled = false
            registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        } else {
            registerButton.isEnabled = true
            registerButton.backgroundColor = .rgb(red: 0, green: 185, blue: 0)
        }
        
    }
    
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // ファイルのサイズなど加工した場合
        if let editImage = info[.editedImage] as? UIImage {
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
            // そのままの画像を受け取る
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentVerticalAlignment = .fill
        profileImageButton.contentHorizontalAlignment = .fill
        
        profileImageButton.clipsToBounds = true
        
        
        
        dismiss(animated: true, completion: nil)
    }
}
