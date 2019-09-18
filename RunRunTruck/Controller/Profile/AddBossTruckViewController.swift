//
//  AddBossTruckViewController.swift
//  RunRunTruck
//
//  Created by yueh on 2019/9/10.
//  Copyright © 2019 yueh. All rights reserved.
//

import UIKit

class AddBossTruckViewController: UIViewController {
    
    @IBOutlet weak var truckTextInput: UITextView!
    @IBOutlet weak var showLogoImage: UIImageView!
    @IBOutlet weak var clickSendBtn: UIButton!
    @IBOutlet weak var upLoadImage: UIButton!
    
    var logoImageUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func setLayout() {
        
        clickSendBtn.layer.cornerRadius = 20
        clickSendBtn.layer.masksToBounds = true
        
        showLogoImage.layer.cornerRadius = UIScreen.main.bounds.width / 3 / 2
        showLogoImage.layer.masksToBounds = true
        showLogoImage.layer.borderWidth = 1
        showLogoImage.layer.borderColor = UIColor.gray.cgColor
        showLogoImage.contentMode = .scaleAspectFill
        showLogoImage.clipsToBounds = true
        
    }
    
    @IBAction func upLoadImageBtn(_ sender: Any) {
        showImagePickerAlert()
    }
    
    func showImagePickerAlert() {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        let imagePickerAlertController = UIAlertController(
            title: "上傳圖片",
            message: "請選擇要上傳的圖片",
            preferredStyle: .actionSheet)
        
        let imageFromLibAction = UIAlertAction(title: "照片圖庫", style: .default) { (Void) in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let imageFromCameraAction = UIAlertAction(title: "相機", style: .default) { (Void) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (Void) in
            
            imagePickerAlertController.dismiss(animated: true, completion: nil)
        }
        
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(imageFromCameraAction)
        imagePickerAlertController.addAction(cancelAction)
        
        present(imagePickerAlertController, animated: true, completion: nil)
        
    }
    
    @IBAction func clickSendBtn(_ sender: Any) {
        
        guard let inputText = truckTextInput.text else { return}
        
        guard inputText.isEmpty == false else {
            print("請跟我們分享你的故事")
            return
        }
        
        let truckName = FirebaseManager.shared.currentUser?.name
        
        guard let name = truckName, let url = self.logoImageUrl else {return}

        FirebaseManager.shared.addTurck(name: name,
                                        img: url,
                                        story: inputText) { [weak self] (truckID) in
                                            
                                            FirebaseManager.shared.addTurckIDInBoss(truckId: truckID)
                                            
                                            DispatchQueue.main.async {
                                                guard let rootVC = AppDelegate.shared.window?.rootViewController
                                                    as? TabBarViewController else { return }
                                                rootVC.tabBar.isHidden = false
                                                let vc = self?.presentingViewController
                                                self?.dismiss(animated: false) {
                                                    vc?.dismiss(animated: false, completion: nil)
                                                }
                                            }
        }
    }
}

extension AddBossTruckViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    internal func imagePickerController(_ picker: UIImagePickerController,
                                        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        // 取得從 UIImagePickerController 選擇的檔案
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            selectedImageFromPicker = pickedImage
            showLogoImage.image = selectedImageFromPicker
 
        }
        
        // 可以自動產生一組獨一無二的 ID 號碼，方便等一下上傳圖片的命名
        let uniqueString = NSUUID().uuidString
        
        // 當判斷有 selectedImage 時，我們會在 if 判斷式裡將圖片上傳
        if let selectedImage = selectedImageFromPicker {
            
            if let uploadData = selectedImage.pngData() {
                
                FirebaseStorageManager.shared.upLoadTruckLogo(
                    imageName: uniqueString,
                    data: uploadData) { (url) in
                                                                
                    guard let imageUrl = url else {return}
                        
                        self.logoImageUrl = imageUrl
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}
