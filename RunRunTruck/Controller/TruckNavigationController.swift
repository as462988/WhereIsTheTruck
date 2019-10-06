//
//  TruckNavigationController.swift
//  RunRunTruck
//
//  Created by yueh on 2019/9/20.
//  Copyright © 2019 yueh. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return visibleViewController?.preferredStatusBarStyle ?? .default
    }
}
