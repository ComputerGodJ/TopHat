//
//  GameViewController.swift
//  Top Hat
//
//  Created by Jonathan Robinson on 11/10/2016.
//  Copyright © 2016 J. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var difficulty = String()
    
    // Load the SKScene, which is an instance of GameScene
    var scene: GameScene?

    override func viewDidLoad() {
        super.viewDidLoad()
        //Stop device auto-locking due to no screen interaction
        UIApplication.shared.isIdleTimerDisabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name:NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name:NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeGame), name:NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        scene = GameScene()
        scene?.difficultyChoice = difficulty
        
        if let view = self.view as! SKView? {
            // Set the scale mode
            scene?.scaleMode = .resizeFill
            //Optimisation
            view.ignoresSiblingOrder = true
            //Show debug information
            view.showsFPS = true
            view.showsNodeCount = true
            scene?.gameVC = self
            // Present the scene
            view.presentScene(scene)
        }
    }
    
    @objc func pauseGame() {
        scene?.isPaused = true
    }
    
    @objc func resumeGame() {
        scene?.isPaused = false
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination
        if let postGameVC = destinationVC as? PostGameController {
            if let game = sender as? GameScene {
                //Re-enable device auto-lock
                UIApplication.shared.isIdleTimerDisabled = false
                //Set variables
                postGameVC.collectedCoins = game.collectedCoins
                postGameVC.points = game.collectedPoints
                postGameVC.collectedXp = game.collectedXp
                postGameVC.scoreMod = game.scoreMod
                postGameVC.coinMod = game.coinsMod
                postGameVC.xpMod = game.xpMod
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
