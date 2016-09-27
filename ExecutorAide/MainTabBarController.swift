//
//  MainTabBarController.swift
//  ExecutorAide
//
//  Created by Tim on 9/16/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    var stages: [Stage]? {
        didSet {
            setupTabBarViews()
        }
    }
    
    var testator: Testator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupTabBarViews() {
        guard let stages = stages else { return }
        for i in 0...stages.count - 1 {
            tabBar.items?[i].title = stages[i].name
        }
        
        
        guard let firstNavigationController = viewControllers?[0] as? UINavigationController else { return }
        guard let firstTabVC = firstNavigationController.viewControllers.first as? StageTableViewController else { return }
        
        
        firstTabVC.stage = stages[0]
//        secondTabVC.stage = stages[1]
//        thirdTabVC.stage = stages[2]
    }
}
