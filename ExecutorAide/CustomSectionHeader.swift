//
//  CustomSectionHeader.swift
//  ExecutorAide
//
//  Created by Tim on 9/28/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

let customSectionHeaderReuseIdentifier = "customSectionHeader"

class CustomSectionHeader: UITableViewHeaderFooterView {

    weak var delegate: SectionHeaderDelegate?
    
    var task: Task?
    
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    func updateHeaderWithTaskInfo() {
        taskNameLabel.text = task?.name
    }
    
    @IBAction func deleteAction(_ sender: AnyObject) {
        guard let task = task else { return }
        delegate?.didTapDeleteSectionButton(withTask: task)
    }
}

protocol SectionHeaderDelegate: class {
    func didTapDeleteSectionButton(withTask task: Task)
}
