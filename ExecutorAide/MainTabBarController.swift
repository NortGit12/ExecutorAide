//
//  MainTabBarController.swift
//  ExecutorAide
//
//  Created by Tim on 9/16/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    var stages: [Stage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarTitles()
    }
    
    func setupTabBarTitles() {
        guard let stages = stages else { return }
        for i in 0...stages.count - 1 {
            tabBar.items?[i].title = stages[i].name
        }
    }
}
