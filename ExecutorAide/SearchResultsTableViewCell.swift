//
//  SearchResultsTableViewCell.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/28/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

class SearchResultsTableViewCell: UITableViewCell {

    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    @IBOutlet weak var resultNameLabel: UILabel!
    @IBOutlet weak var resultDistanceLabel: UILabel!
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    func updateWith(name: String, distance: String) {
        
        resultNameLabel.text = name
        resultDistanceLabel.text = distance
    }

}
