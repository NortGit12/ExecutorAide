//
//  AppearanceController.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/30/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

class AppearanceController {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    // Universal
    static let fontName = "Avenir Next"
    static let titleFontSize: CGFloat = 25.0
    
    // Navigation bar
    static let barBackgroundColor = UIColor(red: 44/255.0, green: 43/255.0, blue: 44/255.0, alpha: 1.0)
    static let navigationItemTextColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    static let navigationItemFontSize: CGFloat = 17.0
    
    // TabBar
    static let tabBarItemFontSize: CGFloat = 16.0
    
    // Content
    static let taskNameFontSize: CGFloat = 20.0
    static let subTaskNameFontSize: CGFloat = 20.0
    static let subTaskDescriptorFontSize: CGFloat = 14.0
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    static func initializeAppearanceDefaults() {
        
        // UINavigationBar
        
        let titleTextAttributes = [NSFontAttributeName: UIFont(name: AppearanceController.fontName, size: AppearanceController.titleFontSize)!, NSForegroundColorAttributeName: UIColor.white]
        
        UINavigationBar.appearance().barTintColor = AppearanceController.barBackgroundColor
        UINavigationBar.appearance().titleTextAttributes = titleTextAttributes
        UINavigationBar.appearance().tintColor = .white
        
        // TabBar
        
        UITabBar.appearance().barTintColor = barBackgroundColor
        UITabBar.appearance().tintColor = UIColor.white           // Color of the selected item
        
        let unselectedTabBarTextColor = UIColor(red: 176/255.0, green: 176/255.0, blue: 185/255.0, alpha: 1.00)
        let selectedTabBarTextColor = UIColor.white
        
        let unselectedTabBarAttributes = [NSFontAttributeName: UIFont(name: AppearanceController.fontName, size: AppearanceController.tabBarItemFontSize)!, NSForegroundColorAttributeName: unselectedTabBarTextColor]
        let selectedTabBarAttributes = [NSFontAttributeName: UIFont(name: AppearanceController.fontName, size: AppearanceController.tabBarItemFontSize)!, NSForegroundColorAttributeName: selectedTabBarTextColor]
        
        UITabBarItem.appearance().setTitleTextAttributes(unselectedTabBarAttributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(selectedTabBarAttributes, for: .selected)
    }
}

extension UIColor {
    
    static func greenAccent() -> UIColor {
        return UIColor(red: 0.075, green: 0.745, blue: 0.149, alpha: 1.00)
    }
    
    static func darkCharcoal() -> UIColor {
        return UIColor(red: 0.173, green: 0.169, blue: 0.173, alpha: 1.00)
    }
    
    static func whiteText() -> UIColor {
        return UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.00)
    }
}























