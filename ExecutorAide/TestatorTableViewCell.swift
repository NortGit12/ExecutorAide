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
        DispatchQueue.main.async {
            self.testatorImageView.layer.masksToBounds = true
            self.testatorImageView.layer.cornerRadius = self.testatorImageView.frame.width/2
            self.testatorImageView.contentMode = .scaleAspectFill
        }
        
    }
    
    func updateCellWithTestator(testator: Testator) {
        DispatchQueue.main.async {
            self.nameLabel.text = testator.name
            guard let imageData = testator.image, let testatorImage = UIImage(data: imageData as Data) else { return }
            self.testatorImageView.image = testatorImage
            self.updateImageView()
        }
    }
}
