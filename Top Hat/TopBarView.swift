//
//  TopBarController.swift
//  Top Hat
//
//  Created by Jonathan Robinson on 11/10/2016.
//  Copyright © 2016 J. All rights reserved.
//

import UIKit
import CoreData

class TopBarView: UIView {
    var coinLabel = UILabel()
    var xpLabel = UILabel()
    
    override func draw(_ rect: CGRect) {
        let context = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
        let userRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        if let user = (try? context?.fetch(userRequest))??.first as? User {
            //MARK: Coin label
            coinLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 50)
            coinLabel.textColor = UIColor.black
            coinLabel.adjustsFontSizeToFitWidth = true
            coinLabel.frame = CGRect(x: bounds.width*0.75, y: bounds.height/30, width: bounds.width*0.2, height: bounds.height)
            coinLabel.text = "Coins: " + String(user.balance)
            addSubview(coinLabel)
            
            //MARK: Xp label
            xpLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 30)
            xpLabel.textColor = UIColor.black
            xpLabel.adjustsFontSizeToFitWidth = true
            xpLabel.frame = CGRect(x: self.bounds.width*0.1, y: bounds.height/30 , width: self.bounds.width*0.5, height: self.bounds.height)
            let currentLevel = Int(floor(sqrt(Double(user.xp))/2))
            let nextXp = Int(4 * pow(Double(currentLevel + 1), 2))
            xpLabel.text = "Xp: " + String(user.xp) + "/" + String(nextXp) + "   (Level: " + String(currentLevel) + ")"
            addSubview(xpLabel)
        }
    }
}
