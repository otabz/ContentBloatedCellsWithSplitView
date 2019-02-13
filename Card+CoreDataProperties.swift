//
//  Card+CoreDataProperties.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 8/27/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Card {

    @NSManaged var child_id: NSNumber?
    @NSManaged var image: Data?

}
