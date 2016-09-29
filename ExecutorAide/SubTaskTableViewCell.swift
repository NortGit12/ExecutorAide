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
        selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateCellWithSubTask(subTask: SubTask) {
        subTaskNameLabel.text = subTask.name
        subTaskDescriptionLabel.text = subTask.descriptor
        updateCheckmarkWithCompletedState(isCompleted: subTask.isCompleted)
    }
    
    func updateCheckmarkWithCompletedState(isCompleted: Bool) {
        if isCompleted {
            checkmarkButton.setImage(UIImage(named: "Completed"), for: .normal)
            animateCheckmarkChange()
        } else {
            checkmarkButton.setImage(UIImage(named: "NotStarted"), for: .normal)
            animateCheckmarkChange()
        }
    }
    
    
    @IBAction func checkmarkTapped(_ sender: AnyObject) {
        delegate?.subTaskTableViewCellDidChangeCompletionState(sender: self)
    }
    
    
}

// Animation

extension SubTaskTableViewCell {
    func animateCheckmarkChange() {
        UIView.animate(withDuration: 0.1, animations: {
            self.checkmarkButton.transform = CGAffineTransform.identity.scaledBy(x: 1.2, y: 1.2)
        }) { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                self.checkmarkButton.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            })
        }
    }
}

protocol SubTaskTableViewCellDelegate: class {
    func subTaskTableViewCellDidChangeCompletionState(sender: SubTaskTableViewCell)
}
