//
//  TestatorTableViewCell.swift
//  ExecutorAide
//
//  Created by Tim on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

let testatorCellReuseIdentifier = "TestatorCell"
let testatorCellHeight = 90

class TestatorTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var testatorImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.accessoryType = .disclosureIndicator
        updateImageView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            self.selectionStyle = .none
        }
    }
    
    func updateImageView() {
        testatorImageView.layer.masksToBounds = true
        testatorImageView.layer.cornerRadius = testatorImageView.frame.width/2
        testatorImageView.contentMode = .scaleAspectFill
    }
    
    func updateCellWithTestator(testator: Testator) {
        nameLabel.text = testator.name
        guard let imageData = testator.image, let testatorImage = UIImage(data: imageData as Data) else { return }
        testatorImageView.image = testatorImage
        updateImageView()
    }
}
