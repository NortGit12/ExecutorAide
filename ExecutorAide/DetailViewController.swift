//
//  DetailViewController.swift
//  ExecutorAide
//
//  Created by Tim on 9/30/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var subTask: SubTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = subTask?.name
    }

    
}
