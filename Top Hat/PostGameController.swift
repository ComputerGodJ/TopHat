//
//  PostGameViewController.swift
//  Top Hat
//
//  Created by Jonathan Robinson on 23/10/2016.
//  Copyright © 2016 J. All rights reserved.
//

import UIKit
import CoreData

class PostGameController: UIViewController {
    
    var collectedCoins = 0
    var points = 0
    var collectedXp = 0
    var scoreMod = 1.0
    var coinMod = 1.0
    var xpMod = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let deviceInfo = UIDevice() //Used to identify device type, for font purposes
        
        //Set up gradient background
        let colourObject = ColourGradient()
        let colourGradient = colourObject.gradient
        colourGradient.frame = view.frame
        view.layer.insertSublayer(colourGradient, at: 0)
        
        //Manage font
        if deviceInfo.model == "iPad" { //Increase font size for iPad devices
            let newFont = UIFont(name: mainMenuButton.titleLabel!.font.fontName, size: 60)!
            mainMenuButton.titleLabel?.font = newFont
            coinLabel.font = newFont
            topTextLabel.font = newFont
            scoreLabel.font = newFont
            xpLabel.font = newFont
        }
        
        print(points)
        print(scoreMod)
        print(collectedCoins)
        print(coinMod)
        print(collectedXp)
        print(xpMod)
        //Set text
        let finalScore = Int(floor(Double(points) * scoreMod))
        let finalCoins = Int(floor(Double(collectedCoins) * coinMod + 0.25 * Double(points)))
        let finalXp = Int(floor(Double(collectedXp)*xpMod + 0.25*Double(collectedCoins)))
        scoreLabel.text = "Points earned: " + String(finalScore)
        coinLabel.text = "Coins awarded: " + String(finalCoins)
        xpLabel.text = "Xp awarded: " + String(finalXp)
        
        //Update player's coin & xp
        let context = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
        let userRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        if let user = (try? context?.fetch(userRequest))??.first as? User {
            user.balance += finalCoins
            let oldLevel = Int(floor(sqrt(Double(user.xp))/2))
            user.xp += finalXp
            let newLevel = Int(floor(sqrt(Double(user.xp))/2))
            if newLevel > oldLevel {
                xpLabel.text? += "   Level up!"
            }
            
            do { //Attempt to save changes to the database
                try context?.save()
                print("Saving...")
            } catch let error { //Process the error if the save fails
                print("Core data error occurred: \(error)")
            }
        }
    }
    //Outlets
    @IBOutlet weak var mainMenuButton: UIButton!
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var topTextLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var xpLabel: UILabel!
}
