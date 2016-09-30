//
//  ServicesCategoriesViewController.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/28/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit
import MapKit

class ServicesCategoriesViewController: UIViewController, SearchResultCellDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    @IBOutlet weak var categoriesSearchBar: UISearchBar!
    @IBOutlet weak var categoriesSearchButton: UIButton!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var categoriesTableView: UITableView!
    
    let locationManager = CLLocationManager()
    
    var categories: [ServiceCategory] = [.Catering, .Cemeteries, .EmergencyServices, .EstateAttorneys, .Florists, .FuneralHomes, .Government, .Hospice, .MemorialMonuments, .PetCareServices, .Restaurants, .StorageUnits, .VeteransOrganizations]
    let regionRadius: CLLocationDistance = 1000
    var currentCoordinate = CLLocationCoordinate2D()
    var currentLocation = CLLocation()
    var currentCity = String()
    var currentRegion = String()
    var currentCountry = String()
    var categorySearchTerm = String()
    var locationSearchTerm = String()
    var searchResponse: MKLocalSearchResponse?
    
    //==================================================
    // MARK: - General
    //==================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoriesSearchBar.delegate = self
        locationSearchBar.delegate = self
        
        setupLocationSupport {
            
            self.performSearch()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        categoriesTableView.reloadData()
    }
    
    //==================================================
    // MARK: - SearchResultCellDelegate
    //==================================================
    
    func cellTapped(cell: ServicesCategoriesTableViewCell) {
        
        categoriesSearchBar.text = ""
        categoriesSearchBar.resignFirstResponder()
        locationSearchBar.resignFirstResponder()
        
        if locationSearchBar.text?.characters.count == 0 {
            
            let alertController = UIAlertController(title: "Location Needed", message: "Enter a location to search and try again.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            
            if let category = cell.serviceCategory
                , let locationSearchTerm = locationSearchBar.text {
                
                self.categorySearchTerm = category.rawValue
                self.locationSearchTerm = locationSearchTerm
                
                self.performSearch(completion: {
                    
                    self.performSegue(withIdentifier: "categoryCellToResultsSegue", sender: cell)
                })
            }
        }
    }
    
    //==================================================
    // MARK: - UISearchBarDelegate
    //==================================================
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        if let categorySearchTerm = categoriesSearchBar.text {
            self.categorySearchTerm = categorySearchTerm
        }
    }
    
    //==================================================
    // MARK: - UITableViewDataSource
    //==================================================

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCategoriesCell", for: indexPath) as? ServicesCategoriesTableViewCell
            else { return UITableViewCell() }
        
        cell.delegate = self
        
        let category = categories[indexPath.row]
        cell.updateWithCategory(category: category)
        
        return cell
    }
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    func setupLocationSupport(completion: (() -> Void)? = nil) {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        if let completion = completion {
            completion()
        }
    }
    
    func forwardGeoCoding(address: String, completion: ((_ coordinate: CLLocationCoordinate2D?) -> Void)? = nil) {
        
        if address.characters.count > 0 {
            
            CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
                
                if let error = error {
                    print("Error with address \"\(address)\": \(error.localizedDescription)")
                    
                    if let completion = completion {
                        completion(nil)
                    }
                }
                
                if let placemarks = placemarks {
                    
                    if placemarks.count == 0 {
                        
                        print("No location found")
                        
                        if let completion = completion {
                            completion(nil)
                        }
                    }
                    
                    if let placemark = placemarks.first {
                        
                        let location = placemark.location
                        let coordinate = location?.coordinate
                        print("\nlat = \(coordinate?.latitude), long = \(coordinate?.longitude)")
                        
                        if let completion = completion {
                            completion(coordinate)
                        }
                        
                    }
                }
            }
        }
    }
    
    func search(forCategory categorySearchTerm: String, nearLocation locationSearchTerm: String, completion: ((_ searchResponse: MKLocalSearchResponse?) -> Void)? = nil) {
        
        // Translate the location into a coordinate
        
        forwardGeoCoding(address: locationSearchTerm) { (coordinate) in
            
            if let coordinate = coordinate {
                
                self.currentCoordinate = coordinate
                
                print("\ncoordinate for \(locationSearchTerm) = \(coordinate)")
                
                // Create a span (area to search) and region for the specified location
                
                let span = MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                
                // Search
                
                let request = MKLocalSearchRequest()
                request.region = region
                request.naturalLanguageQuery = categorySearchTerm
                
                let search = MKLocalSearch(request: request)
                search.start(completionHandler: { (localSearchResponse, error) in
                    
                    if let error = error {
                        print("Error searching for services in a location: \(error.localizedDescription)")
                        
                        if let completion = completion {
                            completion(nil)
                        }
                        
                        return
                    }
                    
                    if let localSearchResponse = localSearchResponse {
                        
                        if let completion = completion {
                            completion(localSearchResponse)
                        }
                    }
                })
            }
        }
    }
    
    func performSearch(completion: (() -> Void)? = nil) {
        
        search(forCategory: self.categorySearchTerm, nearLocation: self.locationSearchTerm) { (localSearchResponse) in
            
            if let localSearchResponse = localSearchResponse {
                
                self.searchResponse = localSearchResponse
            }
            
            if let completion = completion {
                completion()
            }
        }
    }
    
    //==================================================
    // MARK: - Action(s)
    //==================================================
    
    @IBAction func searchCategoriesButtonTapped(_ sender: UIButton) {
        
        categoriesSearchBar.resignFirstResponder()
        locationSearchBar.resignFirstResponder()
        
        if categoriesSearchBar.text?.characters.count == 0 {
            
            let alertController = UIAlertController(title: "New Category Needed", message: "Enter a category to search and try again.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            
            if let categorySearchTerm = categoriesSearchBar.text
                , let locationSearchTerm = locationSearchBar.text {
                
                self.categorySearchTerm = categorySearchTerm
                self.locationSearchTerm = locationSearchTerm
                
                self.performSearch(completion: { 
                    
                    self.performSegue(withIdentifier: "categorySearchToResultsSegue", sender: nil)
                })
            }
        }
    }
    
    //==================================================
    // MARK: - Navigation
    //==================================================
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // How am I getting there?
        
        if segue.identifier == "categorySearchToResultsSegue" {
            
            // Where am I going?
            
            if let searchResultsViewController = segue.destination as? SearchResultsViewController {
                
                // What do I need to pack?
                
                searchResultsViewController.categorySearchTerm = self.categorySearchTerm
                searchResultsViewController.locationSearchTerm = self.locationSearchTerm
                searchResultsViewController.searchResponse = self.searchResponse
                
                // Am I done packing?
                
            }
            
        } else if segue.identifier == "categoryCellToResultsSegue" {
            
            categoriesSearchBar.resignFirstResponder()
            locationSearchBar.resignFirstResponder()
            categoriesSearchBar.text = ""
            
            // Where am I going?
            
            if let searchResultsViewController = segue.destination as? SearchResultsViewController {
                
                // What do I need to pack?
                
                guard let cell = sender as? ServicesCategoriesTableViewCell
                    , let indexPath = categoriesTableView.indexPath(for: cell)
                    else {
                    print("Error identifying the selected cell for segue.")
                    return
                }
                
                guard let locationSearchTerm = self.locationSearchBar.text, locationSearchTerm.characters.count > 0 else {
                    
                    let alertController = UIAlertController(title: "Missing Location", message: "Make sure a location is specified and try again.", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                // Am I done packing?
                
                let category = self.categories[indexPath.row]
                self.categorySearchTerm = category.rawValue
                searchResultsViewController.categorySearchTerm = self.categorySearchTerm
                
                self.locationSearchTerm = locationSearchTerm
                searchResultsViewController.locationSearchTerm = self.locationSearchTerm
                
                searchResultsViewController.searchResponse = self.searchResponse
                
                self.performSearch()
            }
        }
    }

}

extension ServicesCategoriesViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = manager.location else { return }
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            
            if let placemarks = placemarks {
                
                let currentPlacemark = placemarks.first
                
                guard let currentCity = currentPlacemark?.locality
                    , let currentRegion = currentPlacemark?.administrativeArea
                    , let currentCountry = currentPlacemark?.country
                    else { return }
                
                self.currentCity = currentCity
                self.currentRegion = currentRegion
                self.currentCountry = currentCountry
                
                self.locationSearchBar.text = "\(currentCity), \(currentRegion), \(currentCountry)"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Error finding location: \(error.localizedDescription)")
    }
}





























