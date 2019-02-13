//
//  Card.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 8/27/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import Foundation
import CoreData


class Card: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Card", in: context)
        self.init(entity: entity!, insertInto: context)
    }

}
