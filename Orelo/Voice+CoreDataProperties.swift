//
//  Voice+CoreDataProperties.swift
//  Orelo
//
//  Created by sheshkovsky on 03/09/16.
//  Copyright © 2016 Ali Gholami. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Voice {

    @NSManaged var clLatitude: NSNumber?
    @NSManaged var clLongtitude: NSNumber?
    @NSManaged var createdAt: NSDate?
    @NSManaged var createdBy: String?
    @NSManaged var duration: String?
    @NSManaged var fileName: String?
    @NSManaged var title: String?

}
