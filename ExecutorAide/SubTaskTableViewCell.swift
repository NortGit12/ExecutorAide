//
//  SubTaskTableViewCell.swift
//  ExecutorAide
//
//  Created by Tim on 9/16/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

let subTaskCellReuseIdentifier = "TestatorCell"

class SubTaskTableViewCell: UITableViewCell {

    @IBOutlet weak var subTaskNameLabel: UILabel!
    @IBOutlet weak var subTaskDescriptionLabel: UILabel!
    @IBOutlet weak var checkmarkButton: UIButton!

    weak var delegate: SubTaskTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateCellWithSubTask(subTask: SubTask) {
        subTaskNameLabel.text = subTask.name
//        subTaskDescriptionLabel.text = subTask.description
    }
    
    func updateCheckmarkWithCompletedState(isCompleted: Bool) {
        if isCompleted {
            checkmarkButton.imageView?.image = UIImage(named: "")
        } else {
            checkmarkButton.imageView?.image = UIImage(named: "")
        }
    }
    
    @IBAction func checkmarkButtonTapped(sender: AnyObject) {
        let subTask = delegate?.subTaskTableViewCellDidReceiveTap()
        guard let isCompleted = subTask?.isCompleted else { return }
        updateCheckmarkWithCompletedState(isCompleted: isCompleted)
    }
    
}

protocol SubTaskTableViewCellDelegate: class {
    func subTaskTableViewCellDidReceiveTap() -> SubTask
}
