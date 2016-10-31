//
//  HatRackController.swift
//  Top Hat
//
//  Created by Jonathan Robinson on 24/10/2016.
//  Copyright © 2016 J. All rights reserved.
//

import UIKit

class HatRackController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let deviceInfo = UIDevice() //Used to identify device type, for font purposes
        
        //Set up gradient background
        let colourObject = ColourGradient()
        let colourGradient = colourObject.gradient
        colourGradient.frame = view.frame
        view.layer.insertSublayer(colourGradient, at: 0)
        
        //Font handling code
        boostButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        if deviceInfo.model == "iPad" { //Increase font size for iPad devices
            let newFont = UIFont(name: boostButton.titleLabel!.font.fontName, size: 60)!
            hatButton.titleLabel!.font = newFont
            perkButton.titleLabel!.font = newFont
            boostButton.titleLabel!.font = newFont
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBOutlet weak var baseBar: BaseBarView!
    @IBOutlet weak var topBar: TopBarView!
    @IBOutlet weak var hatButton: UIButton!
    @IBOutlet weak var perkButton: UIButton!
    @IBOutlet weak var boostButton: UIButton!
}
