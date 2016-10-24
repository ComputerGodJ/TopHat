//
//  PlatformClass.swift
//  Top Hat
//
//  Created by Jonathan Robinson on 22/10/2016.
//  Copyright © 2016 J. All rights reserved.
//

import Foundation
import SpriteKit

class Platform: SKSpriteNode {
    private var pointsAwarded = false
    var pointValue: Int {
        return 0
    }
    
    public func hasBeenTouched() -> Int {
        if !pointsAwarded {
            pointsAwarded = true
            return pointValue
        }
        return 0
    }
}

class BasicPlatform: Platform {
    override var pointValue: Int {
        return 1
    }
}

class DummyPlatform: Platform {
    override var pointValue: Int {
        return 6
    }
}

class CloudPlatform: DummyPlatform {
    override var pointValue: Int {
        return 5
    }
}

class FragilePlatform: Platform {
    private var pointsAwarded = false
    private var timeAtTouch: Date?
    var timeSinceTouch: TimeInterval {
        return -(timeAtTouch?.timeIntervalSinceNow)!
    }
    override var pointValue: Int {
        return 3
    }
    
    override func hasBeenTouched() -> Int {
        if !pointsAwarded {
            timeAtTouch = Date()
            pointsAwarded = true
            return pointValue
        }
        return 0
    }
}
