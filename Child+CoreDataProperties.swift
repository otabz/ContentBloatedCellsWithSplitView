//
//  Child+CoreDataProperties.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 8/26/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Child {

    @NSManaged var dob: Date?
    @NSManaged var gender: String?
    @NSManaged var name: String?
    @NSManaged var pic: Data?
    @NSManaged var updated_at: Date?
    @NSManaged var id: NSNumber?
    @NSManaged var vaccinations: NSSet?

}
