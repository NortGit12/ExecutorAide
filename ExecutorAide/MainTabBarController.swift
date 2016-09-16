//
//  MainTabBarController.swift
//  ExecutorAide
//
//  Created by Tim on 9/16/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let stage1 = StageViewController()
        let stage1Item = UITabBarItem(title: "Preparation", image: UIImage(named: ""), selectedImage: UIImage(named: ""))
        stage1.tabBarItem = stage1Item
        
        let controllers = [stage1]
        self.viewControllers = controllers
    }

}
