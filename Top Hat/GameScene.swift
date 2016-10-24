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
    var lives = 3
    
    //Constants set at instantiation
    let difficultyTickLength: TimeInterval
    let speedTickLength: TimeInterval
    let platformTable: [Int]
    let sizeTable: [Int]
    let increaseCoinValueChance: Double
    let maximumPlatformDifficulty: Int
    let maximumSizeDifficulty: Int
    
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
    let motionManager = CMMotionManager()
    let frameActionProcessor = SKNode()
    var player = SKSpriteNode()
    var coinCounter = SKLabelNode(fontNamed: "HelveticaNeue-Light")
    var livesCounter = SKLabelNode(fontNamed: "HelveticaNeue-Light")
    let startTime = Date()
    
    //Temporary spaces
    private var randomYIncrease: CGFloat = 0
    
    //Empty initialiser
    override init() {
        super.init()
    }
    //The normal initialiser
    init(_ difficulty: String) {
        
    }
    //An implementation to fix a crash
    override init(size: CGSize) {
        super.init(size: size)
    }
    //Swift told me to do this.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupGame() {
        
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
        //Create the player
        player = SKSpriteNode(imageNamed: "Tophat")
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
        
        let platformType = Int(arc4random_uniform(4)) + 1
        let platform = BasicPlatform(imageNamed: "Platform" + String(platformType))
        randomYIncrease = generateRandomYIncrease()
        platform.position = CGPoint(x: viewWidth, y: 0.2*viewHeight + randomYIncrease)
        platform.zPosition = 1
        platform.setScale(0.5)
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = PhysicsCategory.Platform
        platform.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        platform.physicsBody?.collisionBitMask = PhysicsCategory.None
        let movePlatform = SKAction.moveBy(x: -(viewWidth + 100), y: 0, duration: 4)
        let removePlatform = SKAction.removeFromParent()
        let platformAction = SKAction.sequence([movePlatform, removePlatform])
        
        if arc4random_uniform(10) == 0 { //Add a coin
            let coinType = Int(arc4random_uniform(3)) + 1
            let coin = Powerup(imageNamed: "Coin" + String(coinType))
            coin.setScale(0.1)
            coin.effect = PowerupEffect.coin(coinType)
            coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width/2)
            coin.physicsBody?.affectedByGravity = false
            coin.physicsBody?.categoryBitMask = PhysicsCategory.Powerup
            coin.physicsBody?.contactTestBitMask = PhysicsCategory.Player
            coin.physicsBody?.collisionBitMask = PhysicsCategory.None
            let yIncrement = coin.size.height/2 + platform.size.height
            coin.position = CGPoint(x: platform.position.x, y: platform.position.y + yIncrement)
            addChild(coin)
            coin.run(platformAction)
        }
        
        addChild(platform)
        
        platform.run(platformAction)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        //Configure world properties
        physicsWorld.contactDelegate = self
        //Configure gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.3)
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
        self.isPaused = true
        gameVC.performSegue(withIdentifier: "gameOverSegue", sender: self)
    }
    
    func playerDidCollideWithPlatform(player: SKSpriteNode, platform: Platform) {
        let playerPosition = player.position
        let platformPosition = platform.position
        let playerHeight = player.frame.height / 2
        if (playerPosition.y - playerHeight) > platformPosition.y { //above platform
            let platformWidth = platform.frame.width / 2
            let playerWidth = player.frame.width / 2
            if (playerPosition.x + playerWidth > platformPosition.x - platformWidth) && (playerPosition.x - playerWidth < platformPosition.x + platformWidth) { //touched top
                player.physicsBody?.velocity.dy = 200
            }
        }
    }
    
    func playerDidCollideWithPowerup(player: SKSpriteNode, powerup: Powerup) {
        powerup.removeFromParent()
        switch(powerup.effect) {
        case .coin(let value):
            collectedCoins += value
            setCoinsCounterText()
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
        let timeSinceStart = startTime.timeIntervalSinceNow //Length of time game has been active
        
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
        
        if timeSinceStart
    }
    
}
