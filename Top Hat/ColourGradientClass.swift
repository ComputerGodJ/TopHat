//
//  Shared Code.swift
//  Top Hat
//
//  Created by Jonathan Robinson on 11/10/2016.
//  Copyright © 2016 J. All rights reserved.
//

import Foundation
import UIKit

class ColourGradient {
    let edgeColour = UIColor(colorLiteralRed: 72/255, green: 173/255, blue: 255/255, alpha: 1).cgColor
    let centreColour = UIColor(colorLiteralRed: 171/255, green: 219/255, blue: 255/255, alpha: 1).cgColor
    
    public let gradient = CAGradientLayer()
    
    init() {
        gradient.colors = [edgeColour, centreColour, edgeColour]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
    }
}
