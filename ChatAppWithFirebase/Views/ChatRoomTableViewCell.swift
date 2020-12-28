//
//  ChatRoomTableViewCell.swift
//  ChatAppWithFirebase
//
//  Created by Tetsuya Kamijo on 2020/12/07.
//  Copyright © 2020 Tetsuya Kamijo. All rights reserved.
//

import UIKit
import FirebaseAuth
import Nuke

class ChatRoomTableViewCell: UITableViewCell {
    
    var message: Message? {
        didSet {

            
        }
    }
    

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var partnerMessageTextView: UITextView!
    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var partnerDateLabel: UILabel!
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var partnerMessageTextViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var myMessageTextViewWidthConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        userImageView.layer.cornerRadius = 30
        partnerMessageTextView.layer.cornerRadius = 15
        myMessageTextView.layer.cornerRadius = 15
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkWitchUserMessage()
    }
    
    private func checkWitchUserMessage() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        if uid == message?.uid {
            partnerMessageTextView.isHidden = true
            partnerDateLabel.isHidden = true
            userImageView.isHidden = true
            
            myMessageTextView.isHidden = false
            myDateLabel.isHidden = false
            
            if let message = message {
                myMessageTextView.text = message.message
                let width = estimateFrameForTextView(text: message.message).width + 20
                
                myMessageTextViewWidthConstraint.constant = width
                myDateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
                
            }
            
        } else {
            partnerMessageTextView.isHidden = false
            partnerDateLabel.isHidden = false
            userImageView.isHidden = false
            
            myMessageTextView.isHidden = true
            myDateLabel.isHidden = true
            
            if let urlString = message?.partnerUser?.profileImageURL, let url = URL(string: urlString) {
                Nuke.loadImage(with: url, into: userImageView)
            }
            
            if let message = message {
                partnerMessageTextView.text = message.message
                let width = estimateFrameForTextView(text: message.message).width + 20
                
                partnerMessageTextViewWidthConstraint.constant = width
                partnerDateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
                
            }
        }
    }
    
    // メッセージの幅の長さを自動調整
    private func estimateFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        
        return formatter.string(from: date)
        
    }
}
