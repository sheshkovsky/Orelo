//
//  Voice.swift
//  Orelo
//
//  Created by sheshkovsky on 24/08/16.
//  Copyright © 2016 Ali Gholami. All rights reserved.
//

import Foundation
import CoreData


class Voice: NSManagedObject {
    
    let com = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
// Insert code here to add functionality to your managed object subclass

}
