//
//  Tab1ViewController.swift
//  ExecutorAide
//
//  Created by Tim on 9/23/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

class Tab1ViewController: UIViewController {

    var stageViewController: StageViewController!
    
    var stage: Stage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(stageViewController.showEditing(sender:)))
        self.navigationItem.rightBarButtonItem = rightButton
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stage1ViewEmbed" {
            stageViewController = segue.destination as! StageViewController
            if let stage =  stage {
                stageViewController.stage = stage
            }
        }
    }


}
