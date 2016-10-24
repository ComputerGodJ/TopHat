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
    case platformSpeed(Int)
    case pointsBoost(Int)
    case xpMod(Float)
    case scoreMod(Float)
    case coinMod(Float)
    case coinBoost(Int)
}

class Powerup: SKSpriteNode {
    var effect = PowerupEffect.null
}
