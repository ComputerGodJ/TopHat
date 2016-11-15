//
//  User+CoreDataProperties.swift
//  Top Hat
//
//  Created by Jonathan Robinson on 01/11/2016.
//  Copyright © 2016 J. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var balance: Int32
    @NSManaged public var currentHat: String?
    @NSManaged public var xp: Int32

}
