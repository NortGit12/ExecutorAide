//
//  Detail+CoreDataProperties.swift
//  ExecutorAide
//
//  Created by Jeff Norton on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import Foundation
import CoreData

extension Detail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Detail> {
        return NSFetchRequest<Detail>(entityName: "Detail");
    }

    @NSManaged public var contentValue: String
    @NSManaged public var contentType: String
    @NSManaged public var sortValue: Int
    @NSManaged public var subTask: SubTask

}
