//
//  PerkStoreController.swift
//  Top Hat
//
//  Created by Jonathan Robinson on 01/11/2016.
//  Copyright © 2016 J. All rights reserved.
//

import UIKit
import CoreData

class PerkStoreController: UIViewController {
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    var perks: [Perk] = []
    var refDictionary: [String : Perk] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set up gradient background
        let colourObject = ColourGradient()
        let colourGradient = colourObject.gradient
        colourGradient.frame = view.frame
        view.layer.insertSublayer(colourGradient, at: 0)
        //Process font
        let deviceInfo = UIDevice()
        var newFont = UIFont()
        var newLabelFont = UIFont()
        if deviceInfo.model == "iPad" { //Increase font size for iPad devices
            newFont = UIFont(name: "HelveticaNeue-UltraLight", size: 50)!
            newLabelFont = UIFont(name: "HelveticaNeue-UltraLight", size: 30)!
        } else {
            newFont = UIFont(name: "HelveticaNeue-UltraLight", size: 25)!
            newLabelFont = UIFont(name: "HelveticaNeue-UltraLight", size: 15)!
        }
        doubleCoinLabel.font = newLabelFont
        tripleCoinLabel.font = newLabelFont
        doubleXpLabel.font = newLabelFont
        platformXpLabel.font = newLabelFont
        doubleCoinButton.titleLabel?.font = newFont
        tripleCoinButton.titleLabel?.font = newFont
        doubleXpButton.titleLabel?.font = newFont
        platformXpButton.titleLabel?.font = newFont
        
        //Load perk data
        let perkRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Perk")
        let perkRequestSorter = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        perkRequest.sortDescriptors = [perkRequestSorter]
        perks = (try? context?.fetch(perkRequest)) as! [Perk]
        //Create reference dictionary
        for perk in perks {
            refDictionary[perk.name!] = perk
        }
        //Process interface elements
        for perk in perks {
            updateBar(name: perk.name!)
            updateLabel(name: perk.name!)
        }
    }
    
    private func updateBar(name: String) {
        let perk = refDictionary[name]!
        let progress = Float(perk.level) / 10
        switch name {
        case "doubleCoins":
            doubleCoinBar.setProgress(progress, animated: true)
        case "tripleCoins":
            tripleCoinBar.setProgress(progress, animated: true)
        case "xpFromPlatform":
            platformXpBar.setProgress(progress, animated: true)
        case "xpIncrease":
            doubleXpBar.setProgress(progress, animated: true)
        default:
            break
        }
    }
    
    private func updateLabel(name: String) {
        let perk = refDictionary[name]!
        var nextCostString = ""
        if perk.level < 10 {
            nextCostString = "Cost: " + String(perkCost(level: perk.level + 1, startCost: perk.startCost))
        } else {
            nextCostString = "Cost: ---"
        }
        var currentBoostString = ""
        var nextBoostString = ""
        
        switch name {
        case "doubleCoins":
            currentBoostString = "Current: " + String(Int(perk.level * 5))
            if perk.level == 10 {
                nextBoostString = "Next: ---"
            } else {
                nextBoostString = "Next: " + String(Int(5 * (perk.level + 1)))
            }
            doubleCoinLabel.text = nextCostString + "   " + currentBoostString + "% chance of doubling a normal coin.   " + nextBoostString + "%"
        case "tripleCoins":
            currentBoostString = "Current: " + String(Int(perk.level * 5))
            if perk.level == 10 {
                nextBoostString = "Next: ---"
            } else {
                nextBoostString = "Next: " + String(Int(5 * (perk.level + 1)))
            }
            tripleCoinLabel.text = nextCostString + "   " + currentBoostString + "% chance of tripling a double coin.   " + nextBoostString + "%"
        case "xpFromPlatform":
            currentBoostString = "Current: " + String(Int(perk.level * 10))
            if perk.level == 10 {
                nextBoostString = "Next: ---"
            } else {
                nextBoostString = "Next: " + String(Int(10 * (perk.level + 1)))
            }
            platformXpLabel.text = nextCostString + "   " + currentBoostString + "% chance of receiving xp when jumping on a platform.   " + nextBoostString + "%"
        case "xpIncrease":
            currentBoostString = "Current: " + String(Int(perk.level * 10))
            if perk.level == 10 {
                nextBoostString = "Next: ---"
            } else {
                nextBoostString = "Next: " + String(Int(10 * (perk.level + 1)))
            }
            doubleXpLabel.text = nextCostString + "   " + currentBoostString + "% chance of doubling xp from a powerup.   " + nextBoostString + "%"
        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func buyTap(_ sender: StoreButton) {
        var alert: UIAlertController
        let resultOfPurchase = buyPerk(named: sender.buttonData)
        switch resultOfPurchase {
        case "success":
            alert = UIAlertController(title: "Purchase succesful", message: "Enjoy your upgraded perk!", preferredStyle: UIAlertControllerStyle.alert)
            topBar.setNeedsDisplay()
            updateBar(name: sender.buttonData)
            updateLabel(name: sender.buttonData)
        case "below level":
            alert = UIAlertController(title: "Purchase failed", message: "Purchased failed: you are not a high enough level!", preferredStyle: UIAlertControllerStyle.alert)
        case "not enough money":
            alert = UIAlertController(title: "Purchase failed", message: "Purchased failed: you do not have enough money!", preferredStyle: UIAlertControllerStyle.alert)
        case "level10":
            alert = UIAlertController(title: "Purchase failed", message: "This perk is already at the maximum level!", preferredStyle: UIAlertControllerStyle.alert)
        default:
            alert = UIAlertController(title: "Purchase failed", message: "Something didn't work!", preferredStyle: UIAlertControllerStyle.alert)
        }
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func buyPerk(named perkName: String) -> String {
        let userRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        if let user = (try? context?.fetch(userRequest))??.first as? User {
            if let perk = refDictionary[perkName] {
                if perk.level < 10 {
                    let cost = perkCost(level: perk.level + 1, startCost: perk.startCost)
                    if user.balance >= cost {
                        if xpToLevel(xp: Int(user.xp)) >= 2*(Int(perk.level) + 1) {
                            user.balance -= cost
                            perk.level += 1
                            do { //Attempt to save changes to the database
                                try context?.save()
                                print("Saving purchase...")
                            } catch let error { //Process the error if the save fails
                                print("Core data error occurred: \(error)")
                            }
                            return "success"
                        } else {
                            return "below level"
                        }
                    } else {
                        return "not enough money"
                    }
                } else {
                    return "level10"
                }
            }
        }
        return "unknown error"
    }
    
    private func perkCost(level: Int16, startCost: Int16) -> Int32 {
        let levelMultiplier = pow(Double(level), 2)
        let cost = Int(startCost) * Int(levelMultiplier)
        return Int32(cost)
    }
    
    private func xpToLevel(xp: Int) -> Int {
        return Int(floor(sqrt(Double(xp))/2))
    }
    
    @IBOutlet weak var topBar: TopBarView!
    
    @IBOutlet weak var doubleCoinButton: StoreButton!
    @IBOutlet weak var tripleCoinButton: StoreButton!
    @IBOutlet weak var platformXpButton: StoreButton!
    @IBOutlet weak var doubleXpButton: StoreButton!
    
    
    @IBOutlet weak var doubleCoinBar: UIProgressView!
    @IBOutlet weak var tripleCoinBar: UIProgressView!
    @IBOutlet weak var platformXpBar: UIProgressView!
    @IBOutlet weak var doubleXpBar: UIProgressView!
    
    @IBOutlet weak var doubleCoinLabel: UILabel!
    @IBOutlet weak var tripleCoinLabel: UILabel!
    @IBOutlet weak var platformXpLabel: UILabel!
    @IBOutlet weak var doubleXpLabel: UILabel!
}
