//
//  Task+CoreDataClass.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData


public class Task: SyncableObject, CloudKitManagedObject {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    
    static let type = "Task"
    static let nameKey = "name"
    static let descriptorKey = "descriptor"
    
    
    //==================================================
    // MARK: - Initializers
    //==================================================

}
