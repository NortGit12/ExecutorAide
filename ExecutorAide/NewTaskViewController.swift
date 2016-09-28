//
//  NewTaskViewController.swift
//  ExecutorAide
//
//  Created by Tim on 9/27/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

class NewTaskViewController: UIViewController {
    
    var stage: Stage?
    
    weak var delegate: NewElementDelegate?

    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        // Add new task to stage
        guard let nameText = nameTextField.text, let stage = stage, let sortValue = stage.tasks?.count else { return }
        if !nameText.isEmpty {
            guard let task = Task(name: nameText, sortValue: sortValue, stage: stage) else { return }
            TaskModelController.shared.createTask(task: task, completion: {
                self.dismiss(animated: true, completion: { 
                    self.delegate?.stageWillUpdateWithNewData()
                })
            })
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}


