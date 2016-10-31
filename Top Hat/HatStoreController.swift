//
//  HatStoreController.swift
//  Top Hat
//
//  Created by Jonathan Robinson on 26/10/2016.
//  Copyright © 2016 J. All rights reserved.
//

import UIKit
import CoreData

class HatStoreController: UIViewController {
    
    var hats: [StoreHat] = []
    var boughtDictionary: [String : Bool] = [:]
    var descriptionDictionary: [String : String] = [:]
    var costDictionary: [String : Int] = [:]
    var refDictionary: [String : StoreHat] = [:]
    let context = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up gradient background
        let colourObject = ColourGradient()
        let colourGradient = colourObject.gradient
        colourGradient.frame = view.frame
        view.layer.insertSublayer(colourGradient, at: 0)

        //Load hat data
        let storeRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "StoreHat")
        let storeRequestSorter = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        storeRequest.sortDescriptors = [storeRequestSorter]
        hats = (try? context?.fetch(storeRequest)) as! [StoreHat]
        //Create dictionaries
        for hat in hats {
            boughtDictionary[hat.name!] = hat.isBought
            descriptionDictionary[hat.name!] = hat.hatDescription
            costDictionary[hat.name!] = Int(hat.cost)
            refDictionary[hat.name!] = hat
        }
        
        //Handle button text
        checkButtonText()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkButtonText() {
        //This is declared in this was due to a compiler bug
        var buttons = [button1, button2, button3, button4, button5, button6, button7]
        buttons.append(contentsOf: [button8, button9, button10, button11, button12, button13, button14])
        buttons.append(contentsOf: [button15, button16, button17, button18])
        for index in 0...6 {
            let button = buttons[index]!
            if boughtDictionary[button.hatName]! { //true if bought
                button.setTitle("Wear", for: UIControlState.normal)
            } else {
                button.setTitle("Buy", for: UIControlState.normal)
            }
        }
        //Process font
        let deviceInfo = UIDevice()
        var newFont = UIFont()
        if deviceInfo.model == "iPad" { //Increase font size for iPad devices
            newFont = UIFont(name: "HelveticaNeue-UltraLight", size: 50)!
        } else {
            newFont = UIFont(name: "HelveticaNeue-UltraLight", size: 25)!
        }
        for button in buttons {
            button!.titleLabel!.font = newFont
        }
    }
    
    @IBAction func infoTap(_ sender: StoreButton) {
        let hatName = sender.hatName
        let alertText = descriptionDictionary[hatName]! + "\nCosts: " + String(describing: costDictionary[hatName]!)
        let alert = UIAlertController(title: "Hat description", message: alertText, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func buyHat(hatName: String) -> Bool {
        let userRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        if let user = (try? context?.fetch(userRequest))??.first as? User {
            let cost = costDictionary[hatName]!
            if Int(user.balance) >= cost {
                let hatToBuy = refDictionary[hatName]!
                hatToBuy.isBought = true
                user.balance -= cost
                boughtDictionary[hatName] = true
                print("Bought hat: \(hatName)")
                do { //Attempt to save changes to the database
                    try context?.save()
                    print("Saving purchase...")
                } catch let error { //Process the error if the save fails
                    print("Core data error occurred: \(error)")
                }
                return true
            } else {
                let alert = UIAlertController(title: "Hat description", message: "Purchased failed: you do not have enough money!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        return false
    }
    
    @IBAction func buyTap(_ sender: StoreButton) {
        if sender.titleLabel!.text == "Buy" {
            if buyHat(hatName: sender.hatName) {
                sender.setTitle("Wear", for: UIControlState.normal)
                topBar.setNeedsDisplay()
            }
        } else {
            let userRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
            if let user = (try? context?.fetch(userRequest))??.first as? User {
                user.currentHat = sender.hatName
                do { //Attempt to save changes to the database
                    try context?.save()
                    print("Saving change...")
                } catch let error { //Process the error if the save fails
                    print("Core data error occurred: \(error)")
                }
            }
        }
    }
    
    //Top bar outlet
    @IBOutlet weak var topBar: TopBarView!
    
    //Button outlets: they are treated the same so useful names are not required
    @IBOutlet weak var button1: StoreButton!
    @IBOutlet weak var button2: StoreButton!
    @IBOutlet weak var button3: StoreButton!
    @IBOutlet weak var button4: StoreButton!
    @IBOutlet weak var button5: StoreButton!
    @IBOutlet weak var button6: StoreButton!
    @IBOutlet weak var button7: StoreButton!
    @IBOutlet weak var button8: StoreButton!
    @IBOutlet weak var button9: StoreButton!
    @IBOutlet weak var button10: StoreButton!
    @IBOutlet weak var button11: StoreButton!
    @IBOutlet weak var button12: StoreButton!
    @IBOutlet weak var button13: StoreButton!
    @IBOutlet weak var button14: StoreButton!
    @IBOutlet weak var button15: StoreButton!
    @IBOutlet weak var button16: StoreButton!
    @IBOutlet weak var button17: StoreButton!
    @IBOutlet weak var button18: StoreButton!
}
