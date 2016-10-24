//
//  PostGameViewController.swift
//  Top Hat
//
//  Created by Jonathan Robinson on 23/10/2016.
//  Copyright © 2016 J. All rights reserved.
//

import UIKit

class PostGameController: UIViewController {
    
    var collectedCoins = 0
    var points = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let deviceInfo = UIDevice() //Used to identify device type, for font purposes
        
        //Set up gradient background
        let colourObject = ColourGradient()
        let colourGradient = colourObject.gradient
        colourGradient.frame = view.frame
        view.layer.insertSublayer(colourGradient, at: 0)
        
        if deviceInfo.model == "iPad" { //Increase font size for iPad devices
            let newFont = UIFont(name: mainMenuButton.titleLabel!.font.fontName, size: 60)!
            mainMenuButton.titleLabel?.font = newFont
            coinLabel.font = newFont
            topTextLabel.font = newFont
            scoreLabel.font = newFont
        }
        
        //Set text
        coinLabel.text = "Coins collected: " + String(collectedCoins)
        scoreLabel.text = "Points earned: " + String(points)
    }
    //Outlets
    @IBOutlet weak var mainMenuButton: UIButton!
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var topTextLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
}
