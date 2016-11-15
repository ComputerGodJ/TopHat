//
//  StoreHat+CoreDataProperties.swift
//  Top Hat
//
//  Created by Jonathan Robinson on 01/11/2016.
//  Copyright © 2016 J. All rights reserved.
//

import Foundation
import CoreData


extension StoreHat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoreHat> {
        return NSFetchRequest<StoreHat>(entityName: "StoreHat");
    }

    @NSManaged public var cost: Int16
    @NSManaged public var hatDescription: String?
    @NSManaged public var isBought: Bool
    @NSManaged public var name: String?
    @NSManaged public var level: Int16

}
