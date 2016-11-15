//
//  Perk+CoreDataProperties.swift
//  Top Hat
//
//  Created by Jonathan Robinson on 04/11/2016.
//  Copyright © 2016 J. All rights reserved.
//

import Foundation
import CoreData

extension Perk {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Perk> {
        return NSFetchRequest<Perk>(entityName: "Perk");
    }

    @NSManaged public var level: Int16
    @NSManaged public var name: String?
    @NSManaged public var startCost: Int16
    @NSManaged public var effect: Double

}
