//
//  TruckListViewController.swift
//  RunRunTruck
//
//  Created by yueh on 2019/8/30.
//  Copyright © 2019 yueh. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("我出現了")
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if user == nil {
                
                self.navigationController?.popToRootViewController(animated: false)
            }
        }
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        if FirebaseManager.shared.bossID != nil {
        //
        //            performSegue(withIdentifier: "bossInfo", sender: nil)
        //
        //        } else if FirebaseManager.shared.userID != nil {
        //            guard let userVc = UIStoryboard.profile.instantiateViewController(
        //                withIdentifier: "UserInfoViewController") as? UserInfoViewController else { return }
        //
        //            show(userVc, sender: nil)
        //        }
        
        //new add
        if FirebaseManager.shared.bossID != nil {
            //老闆
            if let bossVC =
                UIStoryboard.profile.instantiateViewController(
                    withIdentifier: "BossInfoViewController") as? BossInfoViewController {
                self.navigationController?.pushViewController(bossVC, animated: false)
            }
        } else if FirebaseManager.shared.userID != nil {
            //使用者
            if let userVc =
                UIStoryboard.profile.instantiateViewController(
                    withIdentifier: "UserInfoViewController") as? UserInfoViewController {
                self.navigationController?.pushViewController(userVc, animated: false)
            }
        }
        //end
    }
}
