//
//  DatabaseInitialiser.swift
//  Top Hat
//
//  Created by Jonathan Robinson on 26/10/2016.
//  Copyright © 2016 J. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DatabaseInitialiser {
    private let context = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    
    public func checkDatabase() {
        checkUser()
        checkStoreData()
        do { //Attempt to save the database
            try context?.save()
            print("Saving...")
        } catch let error { //Process the error if the save fails
            print("Core data error occurred: \(error)")
        }
    }
    
    private func checkUser() {
        let userRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        if (try? context?.fetch(userRequest))??.first == nil {
            //No user found: create and add to database
            if let newUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: context!) as? User {
                newUser.balance = 1000000
                newUser.currentHat = "Default hat"
                print("User added to datastore")
            }
        }
    }
    
    private func checkStoreData() {
        let allStoreHats = ["Default hat", "Giraffe hat", "Military hat", "Party hat", "Top hat", "Vector hat", "Wizard hat"]
        var namesOfFoundHats: [String] = []
        var namesOfHatsToAdd: [String] = []
        var hataDictionary: [String : (Int, String)] = [:]
        hataDictionary["Default hat"] = (0, "We're very generous and give you this hat to start off with.  Please don't make it dirty.") as (Int, String)
        hataDictionary["Giraffe hat"] = (200, "Tired of being a standard hat?  Go giraffe style.") as (Int, String)
        hataDictionary["Military hat"] = (300, "Worried about hitting your head?  This helmet takes care of everything") as (Int, String)
        hataDictionary["Party hat"] = (500, "With this hat, you can gatecrash anyone's party.") as (Int, String)
        hataDictionary["Top hat"] = (10000, "The top hat grants you access into an exclusive group composed of the most elite citizens of society") as (Int, String)
        hataDictionary["Vector hat"] = (2000, "Now you can experience being able to travel in any direction but only travelling one unit of length!") as (Int, String)
        hataDictionary["Wizard hat"] = (1000, "Magic is amazing: so is this hat.") as (Int, String)
        
        let storeRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "StoreHat")
        let storeRequestSorter = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        storeRequest.sortDescriptors = [storeRequestSorter]
        if let hats = (try? context?.fetch(storeRequest)) as? [StoreHat] {
            for hat in hats {
                namesOfFoundHats.append(hat.name!) //Create an array of the names of the hats that are in the store
            }
            for hatName in allStoreHats {
                if !namesOfFoundHats.contains(hatName) {
                    namesOfHatsToAdd.append(hatName) //Add this name to the array if it isn't in the database
                }
            }
            for name in namesOfHatsToAdd { //Add the missing items to the database
                if let newHat = NSEntityDescription.insertNewObject(forEntityName: "StoreHat", into: context!) as? StoreHat {
                    let (hatCost, hatDescription) = hataDictionary[name]!
                    newHat.name = name
                    newHat.cost = Int16(hatCost)
                    newHat.hatDescription = hatDescription
                    if name == "Default hat" {
                        newHat.isBought = true
                    } else {
                        newHat.isBought = false
                    }
                    print("Added the hat \(name) to the datastore")
                }
            }
        }
    }
}
