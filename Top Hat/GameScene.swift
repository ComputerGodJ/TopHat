//
//  GameScene.swift
//  Top Hat
//
//  Created by Jonathan Robinson on 11/10/2016.
//  Copyright © 2016 J. All rights reserved.
//

import SpriteKit
import UIKit
import CoreMotion
import CoreData

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Player: UInt32 = 0b1
    static let Platform: UInt32 = 0b10
    static let Powerup: UInt32 = 0b11
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameVC = UIViewController()
    
    //Gameplay variables
    var playing = true
    var collectedCoins = 0
    var collectedPoints = 0
    var collectedXp = 0
    var lives = 3
    private var platformDifficulty = 0
    private var sizeDifficulty = 0
    private var scoreMod = 0.0
    private var coinsMod = 0.0
    private var xpMod = 0.0
    
    //Values set at creation
    var difficultyChoice = ""
    var difficultyTickLength: TimeInterval = 0
    var speedTickLength: TimeInterval = 0
    var platformTable: [Int] = []
    var sizeTable: [Int] = []
    var increaseCoinValueChance: Double = 0
    var maximumPlatformDifficulty: Int = 0
    var maximumSizeDifficulty: Int = 0
    
    //Values used for game logic or scene
    private var viewHeight: CGFloat {
        return self.frame.height
    }
    private var viewWidth: CGFloat {
        return self.frame.width
    }
    private var playerSpawn: CGPoint {
        return CGPoint(x: size.width/2, y: size.height*0.9)
    }
    private var currentScore: Int {
        return collectedPoints + 2*collectedCoins + 3*collectedXp
    }
    let motionManager = CMMotionManager()
    let frameActionProcessor = SKNode()
    var player = SKSpriteNode()
    var coinCounter = SKLabelNode(fontNamed: "HelveticaNeue-Light")
    var scoreCounter = SKLabelNode(fontNamed: "HelveticaNeue-Light")
    var livesCounter = SKLabelNode(fontNamed: "HelveticaNeue-Light")
    var fragilePlatformsArray: [FragilePlatform] = []
    var speedModifier: TimeInterval = 0
    var platformDifficultyTimer = Timer()
    var speedDifficultyTimer = Timer()
    let context = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    
    //Temporary spaces
    private var randomYIncrease: CGFloat = 0
    
    //Sets variables based on difficulty
    func setVariables(_ difficulty: String) {
        
        switch difficulty {
        case "Zen":
            increaseCoinValueChance = 0.4
            platformTable = [1,1,1,1,1,1,2,2,3,3]
            sizeTable = [4,4,4,4,4,3,3,3,2,2]
            difficultyTickLength = 35
            speedTickLength = 70
            maximumPlatformDifficulty = 3
            maximumSizeDifficulty = 8
        case "Easy":
            increaseCoinValueChance = 0.45
            platformTable = [1,1,1,1,1,2,2,3,3,4]
            sizeTable = [4,4,4,4,3,3,3,2,2,1]
            difficultyTickLength = 30
            speedTickLength = 60
            maximumPlatformDifficulty = 4
            maximumSizeDifficulty = 9
        case "Hard":
            increaseCoinValueChance = 0.55
            platformTable = [1,1,1,2,2,2,3,3,4,4]
            sizeTable = [4,4,4,3,3,3,3,2,2,1]
            difficultyTickLength = 25
            speedTickLength = 50
            maximumPlatformDifficulty = 6
            maximumSizeDifficulty = 12
        case "Expert":
            increaseCoinValueChance = 0.7
            platformTable = [1,1,2,2,3,3,3,4,4,4]
            sizeTable = [4,4,3,3,2,2,2,2,1,1]
            difficultyTickLength = 15
            speedTickLength = 30
            maximumPlatformDifficulty = 8
            maximumSizeDifficulty = 14
        default: break
        }
    }
    
    func setupGame() {
        //Set up variables based on difficulty
        setVariables(difficultyChoice)
        //Set up background        
        backgroundColor = UIColor(colorLiteralRed: 171/255, green: 219/255, blue: 255/255, alpha: 1)
        //MARK: on-screen data labels
        //Coin counter
        coinCounter.position = CGPoint(x: 0.9*viewWidth, y: 0.95*viewHeight)
        coinCounter.fontColor = UIColor.black
        coinCounter.fontSize = viewWidth/50
        setCoinsCounterText()
        self.addChild(coinCounter)
        //Lives counter
        livesCounter.position = CGPoint(x: 0.1*viewWidth, y: 0.95*viewHeight)
        livesCounter.fontColor = UIColor.black
        livesCounter.fontSize = viewWidth/50
        setLivesCounterText()
        self.addChild(livesCounter)
        //Score counter
        scoreCounter.position = CGPoint(x: 0.35*viewWidth, y: 0.95*viewHeight)
        scoreCounter.fontColor = UIColor.black
        scoreCounter.fontSize = viewWidth/50
        setScoreCounterText()
        self.addChild(scoreCounter)
        //Create the player
        let userRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        if let user = (try? context?.fetch(userRequest))??.first as? User {
            player = SKSpriteNode(imageNamed: user.currentHat!)
        }
        player.position = playerSpawn
        player.zPosition = 2
        player.setScale(0.2)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Platform
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        //Add the player
        addChild(player)
        //Configure and run player actions
        let calculateXMotion = SKAction.run{ () in self.calculateXVelocity() }
        let calculateXSequence = SKAction.sequence([calculateXMotion, SKAction.wait(forDuration: 0.05)]) //X velocity is calculated 20 times per second
        let calculateXAction = SKAction.repeatForever(calculateXSequence)
        player.run(calculateXAction)
        //Start accelerometer data tracking
        motionManager.accelerometerUpdateInterval = 0.0333 //Sets interval so data is gathered 30 times per second
        motionManager.startAccelerometerUpdates() //Start data tracking
        //Configure timer
        platformDifficultyTimer = Timer.scheduledTimer(timeInterval: difficultyTickLength, target: self, selector: #selector(self.increaseDifficulty), userInfo: nil, repeats: true)
        speedDifficultyTimer = Timer.scheduledTimer(timeInterval: speedTickLength, target: self, selector: #selector(self.increaseSpeed), userInfo: nil, repeats: true)
    }
    
    func generateRandomYIncrease() -> CGFloat {
        let boundary = viewHeight*0.6
        var newYIncrease = CGFloat(arc4random_uniform(UInt32(boundary)))
        if abs(newYIncrease - randomYIncrease) < 0.15*viewHeight {
            newYIncrease = generateRandomYIncrease()
        }
        return newYIncrease
    }
    
    func setLivesCounterText() {
        livesCounter.text = "Lives: " + String(lives)
    }
    
    func setCoinsCounterText() {
        coinCounter.text = "Coins: " + String(collectedCoins)
    }
    
    func setScoreCounterText() {
        scoreCounter.text = "Score: " + String(collectedPoints)
    }
    
    func calculateXVelocity() {
        if let acceleration = motionManager.accelerometerData?.acceleration {
            let rotation = -atan2(acceleration.x, acceleration.y) + (M_PI/2)
            if rotation > 0 {
                player.physicsBody?.velocity.dx = CGFloat(min(200*rotation, 300))
            }
            else {
                player.physicsBody?.velocity.dx = CGFloat(max(200*rotation, -300))
            }
        }
    }
    
    func spawnPlatform() {
        
        let platformType = platformTable[Int(arc4random_uniform(10))]
        let platformSize = sizeTable[Int(arc4random_uniform(10))]
        let platform: Platform
        switch platformType {
        case 1:
            platform = BasicPlatform(imageNamed: "Platform" + String(platformSize))
        case 2:
            platform = FragilePlatform(imageNamed: "FragilePlatform" + String(ceil(Double(platformSize)/2)))
        case 3:
            platform = CloudPlatform(imageNamed: "CloudPlatform" + String(ceil(Double(platformSize)/2)))
        case 4:
            platform = DummyPlatform(imageNamed: "DummyPlatform" + String(min(platformSize, 3)))
        default:
            platform = BasicPlatform(imageNamed: "Platform" + String(platformSize)) //Shouldn't ever happen
        }
        
        randomYIncrease = generateRandomYIncrease()
        platform.position = CGPoint(x: viewWidth, y: 0.2*viewHeight + randomYIncrease)
        platform.zPosition = 1
        platform.setScale(0.5)
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = PhysicsCategory.Platform
        platform.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        platform.physicsBody?.collisionBitMask = PhysicsCategory.None
        let movePlatform = SKAction.moveBy(x: -(viewWidth + 100), y: 0, duration: 4 + max(speedModifier, -3.9))
        let removePlatform = SKAction.removeFromParent()
        let platformAction = SKAction.sequence([movePlatform, removePlatform])
        
        if arc4random_uniform(10) == 0 { //Add a powerup
            let powerup = createPowerup()
            let yIncrement = powerup.size.height/2 + platform.size.height
            powerup.position = CGPoint(x: platform.position.x, y: platform.position.y + yIncrement)
            addChild(powerup)
            powerup.run(platformAction)
        }
        
        addChild(platform)
        platform.run(platformAction)
    }
    
    func createPowerup() -> Powerup {
        var powerup  = Powerup()
        let powerupType = Int(arc4random_uniform(20))
        if 7...19 ~= powerupType {
            let value = coinValue()
            powerup = Powerup(imageNamed: "Coin" + String(value))
            powerup.effect = PowerupEffect.coin(value)
            powerup.setScale(0.1)
            powerup.physicsBody = SKPhysicsBody(circleOfRadius: powerup.size.width/2)
        }
        else {
            powerup = Powerup(imageNamed: "Powerup")
            powerup.setScale(0.4)
            powerup.physicsBody = SKPhysicsBody(rectangleOf: powerup.size)
            switch powerupType {
            case 0:
                powerup.effect = PowerupEffect.xpBoost(Int(arc4random_uniform(21)) + 20)
            case 1:
                powerup.effect = PowerupEffect.platformSpeed(Double(arc4random_uniform(5))/10)
            case 2:
                powerup.effect = PowerupEffect.pointsBoost(Int(arc4random_uniform(41)) + 40)
            case 3:
                powerup.effect = PowerupEffect.xpMod(Double(arc4random_uniform(11))/100)
            case 4:
                powerup.effect = PowerupEffect.scoreMod(Double(arc4random_uniform(11))/100)
            case 5:
                powerup.effect = PowerupEffect.coinMod(Double(arc4random_uniform(11))/100)
            case 6:
                powerup.effect = PowerupEffect.coinBoost(Int(arc4random_uniform(51)) + 50)
            default: break
            }
        }
        powerup.physicsBody?.affectedByGravity = false
        powerup.physicsBody?.categoryBitMask = PhysicsCategory.Powerup
        powerup.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        powerup.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        return powerup
    }
    
    func coinValue() -> Int {
        var value = 1
        if Double(arc4random_uniform(101))/100 <= increaseCoinValueChance {
            value = 2
            if Double(arc4random_uniform(101))/100 <= increaseCoinValueChance {
                value = 3
            }
        }
        return value
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        //Configure world properties
        physicsWorld.contactDelegate = self
        //Configure gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.3)
        //Run functions
        setupGame()
        playGame()
    }
    
    func playGame() {
        let spawnPlatform = SKAction.run({
            () in
            self.spawnPlatform()
        })
        let delay = SKAction.wait(forDuration: 0.25)
        
        let platformProcesses = SKAction.repeatForever(SKAction.sequence([spawnPlatform, delay]))
        self.run(platformProcesses)
    }
    
    func gameOver() {
        platformDifficultyTimer.invalidate()
        speedDifficultyTimer.invalidate()
        self.isPaused = true
        gameVC.performSegue(withIdentifier: "gameOverSegue", sender: self)
    }
    
    func playerDidCollideWithPlatform(player: SKSpriteNode, platform: Platform) { //Called when a player touches a platform
        let playerPosition = player.position
        let platformPosition = platform.position
        let playerHeight = player.frame.height / 2
        if (playerPosition.y - playerHeight) > platformPosition.y { //above platform
            let platformWidth = platform.frame.width / 2
            let playerWidth = player.frame.width / 2
            if (playerPosition.x + playerWidth > platformPosition.x - platformWidth) && (playerPosition.x - playerWidth < platformPosition.x + platformWidth) { //touched top
                let priorYVelocity = player.physicsBody!.velocity.dy
                player.physicsBody?.velocity.dy = 200
                if let touchedPlatform = platform as? CloudPlatform {
                    collectedPoints += touchedPlatform.hasBeenTouched()
                    touchedPlatform.removeFromParent()
                }
                else if let touchedPlatform = platform as? DummyPlatform {
                    player.physicsBody?.velocity.dy = priorYVelocity
                    collectedPoints += touchedPlatform.hasBeenTouched()
                    touchedPlatform.removeFromParent()
                }
                else if let touchedPlatform = platform as? FragilePlatform {
                    collectedPoints += touchedPlatform.hasBeenTouched()
                    fragilePlatformsArray.append(touchedPlatform)
                }
                else {
                    collectedPoints += platform.hasBeenTouched()
                }
                setScoreCounterText()
            }
        }
    }
    
    func playerDidCollideWithPowerup(player: SKSpriteNode, powerup: Powerup) {
        powerup.removeFromParent()
        switch(powerup.effect) {
        case .coin(let value), .coinBoost(let value):
            collectedCoins += value
            setCoinsCounterText()
        case .pointsBoost(let value):
            collectedPoints += value
            setScoreCounterText()
        case .xpBoost(let value):
            collectedXp += value
        case .coinMod(let value):
            coinsMod += value
        case .scoreMod(let value):
            scoreMod += value
        case .xpMod(let value):
            xpMod += value
        case .platformSpeed(let value):
            let increaseSpeed = SKAction.run { self.speedModifier -= value }
            let decreaseSpeed = SKAction.run { self.speedModifier += value }
            let powerupAction = SKAction.sequence([increaseSpeed, SKAction.wait(forDuration: 10), decreaseSpeed, SKAction.removeFromParent()])
            let powerupNode = SKNode()
            self.addChild(powerupNode)
            powerupNode.run(powerupAction)
        default:
            break
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask == PhysicsCategory.Player) && (secondBody.categoryBitMask == PhysicsCategory.Platform) { //Player collides with platform
            playerDidCollideWithPlatform(player: firstBody.node as! SKSpriteNode, platform: secondBody.node as! Platform)
        }
        else if (firstBody.categoryBitMask == PhysicsCategory.Player) && (secondBody.categoryBitMask == PhysicsCategory.Powerup) { //Player collides with coin
            playerDidCollideWithPowerup(player: firstBody.node as! SKSpriteNode, powerup: secondBody.node as! Powerup)
        }
    }
    
    override func update(_ currentTime: TimeInterval) { //Called each frame
        
        let playerX = player.position.x
        let playerY = player.position.y
        if playerX < 0 {
            player.physicsBody?.velocity.dx = 0
            player.position.x = 0
        }
        else if playerX > viewWidth {
            player.physicsBody?.velocity.dx = 0
            player.position.x = viewWidth
        }
        if playerY > viewHeight {
            player.physicsBody?.velocity.dy = 0
            player.position.y = viewHeight
        }
        else if playerY <= 0 {
            lives -= 1
            if lives == 0 {
                gameOver()
            }
            setLivesCounterText()
            player.position = playerSpawn
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        }
        if fragilePlatformsArray.isEmpty == false {
            let platform = fragilePlatformsArray[0]
            if platform.timeSinceTouch >= 0.5 {
                platform.removeFromParent()
                fragilePlatformsArray.remove(at: 0)
            }
        }
    }
    
    func increasePlatformDifficulty() {
        var completed = false
        var easiestPlatform = 1
        while (completed == false) {
            for i in 0...9 { //0-9 inc.
                if platformTable[i] == easiestPlatform {
                    platformTable[i] += 1
                    completed = true
                    break
                }
            }
            easiestPlatform += 1
        }
    }
    
    func increaseSizeDifficulty() {
        var completed = false
        var biggestSize = 4
        while (completed == false) {
            for i in 0...9 { //0-9 inc.
                if sizeTable[i] == biggestSize {
                    sizeTable[i] -= 1
                    completed = true
                    break
                }
            }
            biggestSize -= 1
        }
    }
    
    func increaseDifficulty() {
        if arc4random_uniform(2) == 0 && platformDifficulty < maximumPlatformDifficulty {
            increasePlatformDifficulty()
        }
        else if sizeDifficulty < maximumSizeDifficulty {
            increaseSizeDifficulty()
        }
    }
    
    func increaseSpeed() {
        speedModifier -= 0.4
    }
    
}
