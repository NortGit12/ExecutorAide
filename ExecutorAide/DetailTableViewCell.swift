//
//  DetailTableViewCell.swift
//  ExecutorAide
//
//  Created by Tim on 10/20/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

let detailCellReuseIdentifier = "DetailCell"

class DetailTableViewCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCellWithDetail(detail: Detail) {
        typeLabel.text = detail.contentType
        valueLabel.text = detail.contentValue
    }
    
}
