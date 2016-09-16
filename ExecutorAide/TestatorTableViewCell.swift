//
//  TestatorTableViewCell.swift
//  ExecutorAide
//
//  Created by Tim on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

let testatorCellReuseIdentifier = "TestatorCell"

class TestatorTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var testatorImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.accessoryType = .DisclosureIndicator
        
        testatorImageView.layer.masksToBounds = true
        testatorImageView.layer.cornerRadius = testatorImageView.frame.width/2
        //testatorImageView.image =
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            self.selectionStyle = .None
        }
    }
    
    func updateCellWithTestator(testator: Testator) {
        nameLabel.text = testator.name
        testatorImageView.image = testator.image
    }
    
}
