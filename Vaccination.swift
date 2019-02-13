//
//  Vaccination.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 9/15/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import Foundation
import CoreData


class Vaccination: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Vaccination", in: context)
        self.init(entity: entity!, insertInto: context)
    }
}
