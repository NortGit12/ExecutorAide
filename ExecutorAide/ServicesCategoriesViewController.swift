//
//  ServicesCategoriesViewController.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/28/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit
import MapKit

class ServicesCategoriesViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    @IBOutlet weak var categoriesSearchBar: UISearchBar!
    @IBOutlet weak var categoriesSearchButton: UIButton!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var categoriesTableView: UITableView!
    
    let locationManager = CLLocationManager()
    
    var categories: [ServiceCategory] = [.Catering, .Cemeteries, .EmergencyServices, .EstateAttorneys, .Florists, .FuneralHomes, .Government, .Hospice, .MemorialMonuments, .Restaurants, .StorageUnits, .VeteransOrganizations]
    let regionRadius: CLLocationDistance = 1000
    var currentCoordinate = CLLocationCoordinate2D()
    var currentLocation = CLLocation()
    var currentCity = String()
    var currentRegion = String()
    var currentCountry = String()
    var currentPostalCode = String()
    var categorySearchTerm = String()
    var locationSearchTerm = String()
    
    //==================================================
    // MARK: - General
    //==================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoriesSearchBar.delegate = self
        locationSearchBar.delegate = self
        
        setupLocationSupport()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        categoriesTableView.reloadData()
    }
    
    //==================================================
    // MARK: - UISearchBarDelegate
    //==================================================
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        if let categorySearchTerm = categoriesSearchBar.text {
            self.categorySearchTerm = categorySearchTerm
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let categorySearchTerm = categoriesSearchBar.text
            , let locationSearchTerm = locationSearchBar.text
            else { return }   // where searchText.characters.count > 0
        
        self.categorySearchTerm = categorySearchTerm
        self.locationSearchTerm = locationSearchTerm
        
        search(forCategory: categorySearchTerm, nearLocation: locationSearchTerm)
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
        
        let category = categories[indexPath.row]
        cell.updateWithCategory(category: category)
        
        return cell
    }
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    func setupLocationSupport() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func forwardGeoCoding(address: String, completion: ((_ coordinate: CLLocationCoordinate2D?) -> Void)? = nil) {
        
        CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
            
            if let error = error {
                print("Error with address: \(error.localizedDescription)")
                
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
    
    func search(forCategory categorySearchTerm: String, nearLocation locationSearchTerm: String) {
        
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
                    
                    print("Is self.currentCoorindate saved?")
                })
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
                
                performSegue(withIdentifier: "categorySearchToResultsSegue", sender: nil)
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
                
                // Am I done packing?
                
            }
            
        } else if segue.identifier == "categoryCellToResultsSegue" {
            
            categoriesSearchBar.resignFirstResponder()
            locationSearchBar.resignFirstResponder()
            categoriesSearchBar.text = ""
            
            // Where am I going?
            
            if let searchResultsViewController = segue.destination as? SearchResultsViewController {
            
                // What do I need to pack?
                
                guard let locationSearchTerm = locationSearchBar.text, locationSearchTerm.characters.count > 0 else {
                    
                    let alertController = UIAlertController(title: "Missing Location", message: "Make sure a location is specified and try again.", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    present(alertController, animated: true, completion: nil)
                    return
                }
                
                guard let index = categoriesTableView.indexPathForSelectedRow?.row
                    else {
                        print("Error: Could not identify the selected category row.")
                        return
                    }
                
                let category = categories[index]
                self.categorySearchTerm = category.rawValue
                searchResultsViewController.categorySearchTerm = self.categorySearchTerm
                
                self.locationSearchTerm = locationSearchTerm
                searchResultsViewController.locationSearchTerm = self.locationSearchTerm
            
                // Am I done packing?
            
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
            
            if let lastLocation = locations.last {
                
                let centerOfCurrentLocation = CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
                
                if let placemarks = placemarks {
                    
                    let currentPlacemark = placemarks.first
                    
                    guard let currentCity = currentPlacemark?.locality
                        , let currentRegion = currentPlacemark?.administrativeArea
                        , let currentPostalCode = currentPlacemark?.postalCode
                        , let currentCountry = currentPlacemark?.country
                        else { return }
                    
                    self.currentCity = currentCity
                    self.currentRegion = currentRegion
                    self.currentPostalCode = currentPostalCode
                    self.currentCountry = currentCountry
                    
                    self.locationSearchBar.text = "\(currentCity), \(currentRegion), \(currentCountry)"
                    
                    print("Current location = \(currentCity), \(currentRegion), \(currentCountry) [\(centerOfCurrentLocation.latitude), \(centerOfCurrentLocation.longitude)]")
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Error finding location: \(error.localizedDescription)")
    }
}





























