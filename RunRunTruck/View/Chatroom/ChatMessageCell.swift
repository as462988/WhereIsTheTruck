//
//  ChatRoomTableViewCell.swift
//  RunRunTruck
//
//  Created by yueh on 2019/9/3.
//  Copyright © 2019 yueh. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    static let avatarImgWidth: CGFloat = 50
    static let avatarImgHeight: CGFloat = 50
    static let usrNameLabelHeight: CGFloat = 20
    static let userNameLabelWidth: CGFloat = 100
    
    var nameTextLabel: UILabel?
    var textView: UITextView!
    var profileImageView: UIImageView?
    var bubbleView: UIView!
    
    var textViewHeightAnchor: NSLayoutConstraint?
     var bubbleHeightAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.profileImageView = createProfileInmageView()
        self.configureProfileInmageView()
        self.nameTextLabel = createNameLabel()
        self.configureNameLabel()
        self.bubbleView = createBubbleView()
        self.configureBubbleView()
        self.textView = createTextView()
        self.configureTextView()
        addViews()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemwnted")
    }
    
    func createProfileInmageView() -> UIImageView? { return UIImageView() }
    
    func configureProfileInmageView() {
        if let imageView = self.profileImageView {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = imageView.frame.width / 2
            imageView.layer.masksToBounds = true
            imageView.contentMode = ContentMode.scaleAspectFill
        }
    }
    
    func createNameLabel() -> UILabel? { return UILabel() }
    
    func  configureNameLabel() {
        if let nameLabel = self.nameTextLabel {
            nameLabel.textColor = UIColor(r: 61, g: 61, b: 61)
            nameLabel.font = UIFont.systemFont(ofSize: 16)
            nameLabel.backgroundColor = .clear
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    final func createBubbleView() -> UIView { return UIView() }
    
    func configureBubbleView() {
        if let bubbleView = self.bubbleView {

            bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            bubbleView.translatesAutoresizingMaskIntoConstraints = false
            bubbleView.layer.cornerRadius = 6
        }
    }
    
    final func createTextView() -> UITextView { return UITextView() }
    
    func configureTextView() {
        if let textView = self.textView {
            textView.textColor = UIColor(r: 61, g: 61, b: 61)
            textView.font = UIFont.systemFont(ofSize: 16)
//            textView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            textView.backgroundColor = .clear
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.layer.cornerRadius = 6
            textView.textContainer.lineFragmentPadding = 5
            textView.textContainerInset = .zero
        }
    }
    
    final func setupCellValue(text: String, name: String?, image: String?) {
        if let nameLabel = nameTextLabel {
            nameLabel.text = name
        }
        if let imageView = profileImageView {
            imageView.image = UIImage.asset(.Icon_UserImage)
        }
        textView.text = text
    }
    
    final func addViews() {
        if let imageView = profileImageView {
            self.addSubview(imageView)
        }
        
        if let  nameLabel = nameTextLabel {
            self.addSubview(nameLabel)
            
        }
        self.addSubview(bubbleView)
        self.addSubview(textView)
    }
    
    func setupLayout() {
        
        guard let nameLabel = nameTextLabel, let imageView = profileImageView else {
            return
        }
        
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: ChatMessageCell.avatarImgWidth).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: ChatMessageCell.avatarImgHeight).isActive = true
        //名稱
        nameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 4).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: ChatMessageCell.usrNameLabelHeight).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: ChatMessageCell.userNameLabelWidth).isActive = true
        //聊天背景
        bubbleView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4).isActive = true
        bubbleView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        bubbleHeightAnchor = bubbleView.heightAnchor.constraint(equalToConstant: 1)
        bubbleHeightAnchor?.isActive = true
        
        //聊天文字
        textView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 5).isActive = true
        textView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 4).isActive = true
        textView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor).isActive = true
//        textView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -2).isActive = true
        textView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor, constant: -5).isActive = true
//        textView.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
//        textViewHeightAnchor = textView.heightAnchor.constraint(equalToConstant: 1)
//        textViewHeightAnchor?.isActive = true

    }
}
