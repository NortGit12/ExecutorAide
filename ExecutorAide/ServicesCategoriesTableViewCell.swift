//
//  ServicesCategoriesTableViewCell.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/28/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

class ServicesCategoriesTableViewCell: UITableViewCell {

    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    //==================================================
    // MARK: - Methods
    //==================================================

    func updateWithCategory(category: ServiceCategory) {
        
        switch category {
        case .Catering:
            categoryImageView.image = UIImage(named: ServiceCategory.Catering.rawValue)
            categoryLabel.text = "\(ServiceCategory.Catering.rawValue)"
        case .Cemeteries:
            categoryImageView.image = UIImage(named: ServiceCategory.Cemeteries.rawValue)
            categoryLabel.text = "\(ServiceCategory.Cemeteries.rawValue)"
        case .EmergencyServices:
            categoryImageView.image = UIImage(named: ServiceCategory.EmergencyServices.rawValue)
            categoryLabel.text = "\(ServiceCategory.EmergencyServices.rawValue)"
        case .EstateAttorneys:
            categoryImageView.image = UIImage(named: ServiceCategory.EstateAttorneys.rawValue)
            categoryLabel.text = "\(ServiceCategory.EstateAttorneys.rawValue)"
        case .Florists:
            categoryImageView.image = UIImage(named: ServiceCategory.Florists.rawValue)
            categoryLabel.text = "\(ServiceCategory.Florists.rawValue)"
        case .FuneralHomes:
            categoryImageView.image = UIImage(named: ServiceCategory.FuneralHomes.rawValue)
            categoryLabel.text = "\(ServiceCategory.FuneralHomes.rawValue)"
        case .Government:
            categoryImageView.image = UIImage(named: ServiceCategory.Government.rawValue)
            categoryLabel.text = "\(ServiceCategory.Government.rawValue)"
        case .Hospice:
            categoryImageView.image = UIImage(named: ServiceCategory.Hospice.rawValue)
            categoryLabel.text = "\(ServiceCategory.Hospice.rawValue)"
        case .MemorialMonuments:
            categoryImageView.image = UIImage(named: ServiceCategory.MemorialMonuments.rawValue)
            categoryLabel.text = "\(ServiceCategory.MemorialMonuments.rawValue)"
        case .PetCareServices:
            categoryImageView.image = UIImage(named: ServiceCategory.PetCareServices.rawValue)
            categoryLabel.text = "\(ServiceCategory.PetCareServices.rawValue)"
        case .Restaurants:
            categoryImageView.image = UIImage(named: ServiceCategory.Restaurants.rawValue)
            categoryLabel.text = "\(ServiceCategory.Restaurants.rawValue)"
        case .StorageUnits:
            categoryImageView.image = UIImage(named: ServiceCategory.StorageUnits.rawValue)
            categoryLabel.text = "\(ServiceCategory.StorageUnits.rawValue)"
        case .VeteransOrganizations:
            categoryImageView.image = UIImage(named: ServiceCategory.VeteransOrganizations.rawValue)
            categoryLabel.text = "\(ServiceCategory.VeteransOrganizations.rawValue)"
        }
    }
}


























