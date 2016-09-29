//
//  SearchResultsViewController.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/28/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    @IBOutlet weak var resultsHeaderLabel: UILabel!
    @IBOutlet weak var resultsTableView: UITableView!
    
    var locations = [CLLocation]()
    
    var categorySearchTerm: String?
    var locationSearchTerm: String?
    var searchResponse: MKLocalSearchResponse?
    
    //==================================================
    // MARK: - General
    //==================================================

    override func viewDidLoad() {
        super.viewDidLoad()

        if let categorySearchTerm = self.categorySearchTerm
            , let locationSearchTerm = self.locationSearchTerm
            , let localSearchResponse = self.searchResponse {
            
            resultsTableView.rowHeight = UITableViewAutomaticDimension
            resultsTableView.estimatedRowHeight = 50
            
            resultsHeaderLabel.text = "Search results for \"\(categorySearchTerm)\" in \(locationSearchTerm)"
        }
    }

    //==================================================
    // MARK: - UITableViewDataSource
    //==================================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchResponse?.mapItems.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as? SearchResultsTableViewCell
            , let item = searchResponse?.mapItems[indexPath.row]
            else { return UITableViewCell() }
        
        print("item[\(indexPath.row)] = \(item)")
        cell.updateWith(name: (item.name)!, distance: "2.0mi")
        
        return cell
    }
    
    //==================================================
    // MARK: -
    //==================================================
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let localSearchResponse = self.searchResponse {
            
            let mapItem = localSearchResponse.mapItems[indexPath.row]
            
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
        }
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
