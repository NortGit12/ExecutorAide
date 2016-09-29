//
//  ServicesCategoriesTableViewCell.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/28/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

protocol SearchResultCellDelegate: class {
    
    func cellTapped(cell: ServicesCategoriesTableViewCell)
}

class ServicesCategoriesTableViewCell: UITableViewCell {

    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    @IBOutlet weak var imageViewButton: UIButton!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var serviceCategory: ServiceCategory?
    weak var delegate: SearchResultCellDelegate?
    
    //==================================================
    // MARK: - Methods
    //==================================================

    func updateWithCategory(category: ServiceCategory) {
        
        switch category {
        case .Catering:
            self.serviceCategory = .Catering
            categoryImageView.image = UIImage(named: ServiceCategory.Catering.rawValue)
            categoryLabel.text = "\(ServiceCategory.Catering.rawValue)"
        case .Cemeteries:
            self.serviceCategory = .Cemeteries
            categoryImageView.image = UIImage(named: ServiceCategory.Cemeteries.rawValue)
            categoryLabel.text = "\(ServiceCategory.Cemeteries.rawValue)"
        case .EmergencyServices:
            self.serviceCategory = .EmergencyServices
            categoryImageView.image = UIImage(named: ServiceCategory.EmergencyServices.rawValue)
            categoryLabel.text = "\(ServiceCategory.EmergencyServices.rawValue)"
        case .EstateAttorneys:
            self.serviceCategory = .EstateAttorneys
            categoryImageView.image = UIImage(named: ServiceCategory.EstateAttorneys.rawValue)
            categoryLabel.text = "\(ServiceCategory.EstateAttorneys.rawValue)"
        case .Florists:
            self.serviceCategory = .Florists
            categoryImageView.image = UIImage(named: ServiceCategory.Florists.rawValue)
            categoryLabel.text = "\(ServiceCategory.Florists.rawValue)"
        case .FuneralHomes:
            self.serviceCategory = .FuneralHomes
            categoryImageView.image = UIImage(named: ServiceCategory.FuneralHomes.rawValue)
            categoryLabel.text = "\(ServiceCategory.FuneralHomes.rawValue)"
        case .Government:
            self.serviceCategory = .Government
            categoryImageView.image = UIImage(named: ServiceCategory.Government.rawValue)
            categoryLabel.text = "\(ServiceCategory.Government.rawValue)"
        case .Hospice:
            self.serviceCategory = .Hospice
            categoryImageView.image = UIImage(named: ServiceCategory.Hospice.rawValue)
            categoryLabel.text = "\(ServiceCategory.Hospice.rawValue)"
        case .MemorialMonuments:
            self.serviceCategory = .MemorialMonuments
            categoryImageView.image = UIImage(named: ServiceCategory.MemorialMonuments.rawValue)
            categoryLabel.text = "\(ServiceCategory.MemorialMonuments.rawValue)"
        case .PetCareServices:
            self.serviceCategory = .PetCareServices
            categoryImageView.image = UIImage(named: ServiceCategory.PetCareServices.rawValue)
            categoryLabel.text = "\(ServiceCategory.PetCareServices.rawValue)"
        case .Restaurants:
            self.serviceCategory = .Restaurants
            categoryImageView.image = UIImage(named: ServiceCategory.Restaurants.rawValue)
            categoryLabel.text = "\(ServiceCategory.Restaurants.rawValue)"
        case .StorageUnits:
            self.serviceCategory = .StorageUnits
            categoryImageView.image = UIImage(named: ServiceCategory.StorageUnits.rawValue)
            categoryLabel.text = "\(ServiceCategory.StorageUnits.rawValue)"
        case .VeteransOrganizations:
            self.serviceCategory = .VeteransOrganizations
            categoryImageView.image = UIImage(named: ServiceCategory.VeteransOrganizations.rawValue)
            categoryLabel.text = "\(ServiceCategory.VeteransOrganizations.rawValue)"
        }
    }
    
    //==================================================
    // MARK: - Actions
    //==================================================
    
    @IBAction func imageViewButtonTapped(sender: UIButton) {
        
        if let delegate = delegate {
            
            delegate.cellTapped(cell: self)
        }
    }
}


























