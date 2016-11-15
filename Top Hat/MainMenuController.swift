//
//  MainMenuController.swift
//  Top Hat
//
//  Created by Jonathan Robinson on 11/10/2016.
//  Copyright © 2016 J. All rights reserved.
//

import UIKit

class MainMenuController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let deviceInfo = UIDevice() //Used to identify device type, for font purposes
        
        //Set up gradient background
        let colourObject = ColourGradient()
        let colourGradient = colourObject.gradient
        colourGradient.frame = view.frame
        view.layer.insertSublayer(colourGradient, at: 0)
        
        //Font handling code
        achievementButton.titleLabel?.adjustsFontSizeToFitWidth = true //Fixes text for iphone 4S
        
        if deviceInfo.model == "iPad" { //Increase font size for iPad devices
            let newFont = UIFont(name: achievementButton.titleLabel!.font.fontName, size: 60)!
            playButton.titleLabel!.font = newFont
            storeButton.titleLabel!.font = newFont
            highscoreButton.titleLabel!.font = newFont
            achievementButton.titleLabel!.font = newFont
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UI element outlets
    @IBOutlet weak var topBar: TopBarView!
    @IBOutlet weak var baseBar: BaseBarView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var highscoreButton: UIButton!
    @IBOutlet weak var achievementButton: UIButton!
    
}
