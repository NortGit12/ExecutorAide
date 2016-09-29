//
//  SearchResultsViewController.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/28/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit
import CoreLocation

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    @IBOutlet weak var testTextView: UITextView!
//    @IBOutlet weak var resultsTitleLabel: UILabel!
//    @IBOutlet weak var resultsTableView: UITableView!
    
    var locations = [CLLocation]()
    
    var categorySearchTerm: String?
    var locationSearchTerm: String?
    
    //==================================================
    // MARK: - General
    //==================================================

    override func viewDidLoad() {
        super.viewDidLoad()

        if let categorySearchTerm = self.categorySearchTerm, let locationSearchTerm = self.locationSearchTerm {
            
            testTextView.text = "categorySearchTerm = \(categorySearchTerm)\nlocationSearchTerm = \(locationSearchTerm)"
        }
    }

    //==================================================
    // MARK: - UITableViewDataSource
    //==================================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        return cell
    }

    /*
    //==================================================
    // MARK: - Navigation
    //==================================================

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
