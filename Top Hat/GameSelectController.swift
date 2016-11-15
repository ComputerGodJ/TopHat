//
//  GameSelectController.swift
//  Top Hat
//
//  Created by Jonathan Robinson on 24/10/2016.
//  Copyright © 2016 J. All rights reserved.
//

import UIKit

class GameSelectController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let deviceInfo = UIDevice() //Used to identify device type, for font purposes
        
        //Set up gradient background
        let colourObject = ColourGradient()
        let colourGradient = colourObject.gradient
        colourGradient.frame = view.frame
        view.layer.insertSublayer(colourGradient, at: 0)
        
        //Font handling code
        
        if deviceInfo.model == "iPad" { //Increase font size for iPad devices
            let newFont = UIFont(name: expertButton.titleLabel!.font.fontName, size: 60)!
            zenButton.titleLabel?.font = newFont
            easyButton.titleLabel?.font = newFont
            hardButton.titleLabel?.font = newFont
            expertButton.titleLabel?.font = newFont
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destination
        if let gameVC = destinationVC as? GameViewController {
            if let button = sender as? UIButton {
                gameVC.difficulty = button.titleLabel!.text!
            }
        }
    }
    @IBOutlet weak var zenButton: UIButton!
    @IBOutlet weak var easyButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    @IBOutlet weak var expertButton: UIButton!

}
