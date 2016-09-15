//
//  SyncableObject+CoreDataProperties.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData


extension SyncableObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SyncableObject> {
        return NSFetchRequest<SyncableObject>(entityName: "SyncableObject");
    }

    @NSManaged public var recordIDData: NSData?
    @NSManaged public var recordName: String

}
