//
//  Vaccination+CoreDataProperties.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 9/16/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Vaccination {

    @NSManaged var due_on: Date?
    @NSManaged var stage_id: String?
    @NSManaged var performed_on: Date?
    @NSManaged var status: String?
    @NSManaged var proof: Data?
    @NSManaged var child: Child?
    @NSManaged var vaccines: NSSet?

}
