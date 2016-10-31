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
    
    override func draw(_ rect: CGRect) {
        let context = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
        let userRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        if let user = (try? context?.fetch(userRequest))??.first as? User {
            coinLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 50)
            coinLabel.textColor = UIColor.black
            coinLabel.adjustsFontSizeToFitWidth = true
            coinLabel.frame = CGRect(x: bounds.width*0.75, y: bounds.height/10, width: bounds.width*0.2, height: bounds.height*0.9)
            coinLabel.text = "Coins: " + String(user.balance)
            addSubview(coinLabel)
        }
    }
}
