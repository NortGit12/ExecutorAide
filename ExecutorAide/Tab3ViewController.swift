//
//  Tab3ViewController.swift
//  ExecutorAide
//
//  Created by Tim on 9/23/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

class Tab3ViewController: UIViewController {

    var stageViewController: StageViewController!
    
    var stage: Stage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stage3ViewEmbed" {
            stageViewController = segue.destination as! StageViewController
            if let stage =  stage {
                stageViewController.stage = stage
            }
        }
    }

}
