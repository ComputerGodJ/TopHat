//
//  PowerupClasses.swift
//  Top Hat
//
//  Created by Jonathan Robinson on 23/10/2016.
//  Copyright © 2016 J. All rights reserved.
//

import Foundation
import SpriteKit

enum PowerupEffect {
    case null //Exists for initialisation purposes
    case coin(Int)
    case xpBoost(Int)
    case platformSpeed(TimeInterval)
    case pointsBoost(Int)
    case xpMod(Double)
    case scoreMod(Double)
    case coinMod(Double)
    case coinBoost(Int)
}

class Powerup: SKSpriteNode {
    var effect = PowerupEffect.null
}
