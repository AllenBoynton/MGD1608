//
//  MainMenu.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/20/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class MainMenu: SKScene {
    
    var infoButton = SKSpriteNode()
    
    func viewDidLoad() {
        viewDidLoad()
        
        if let scene = GameScene.unarchiveFromFile("InstructionScene") as? InstructionScene {
            // Configure the view.
            let skView = self.view as SKView!
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFit
            
            skView.presentScene(scene)
        }
    }
    
    func shouldAutorotate() -> Bool {
        return true
    }
    
    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.Landscape
        } else {
            return UIInterfaceOrientationMask.LandscapeLeft
        }
    }

    
    override func didMoveToView(view: SKView) {
        
        infoButton = SKSpriteNode(imageNamed: "info")
        infoButton.zPosition = 100
        infoButton.size = CGSize(width: 30, height: 30)
        infoButton.position = CGPoint(x: 25, y: 25)
        infoButton.name = "Info"
        
        // Adds background sound to Main Menu - one time occurance - see no need for pre-load
        bgMusic = SKAudioNode(fileNamed: "bgMusic.mp3") 
        bgMusic.autoplayLooped = true
        self.addChild(bgMusic)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let game: GameScene = GameScene(fileNamed: "GameScene")!
        game.scaleMode = .AspectFill
        let transition: SKTransition = SKTransition.moveInWithDirection(.Down, duration: 2.0)
        self.view?.presentScene(game, transition: transition)
        
        // Touch screen to play
        let screenText = SKLabelNode(fontNamed: "guardianpi")
        screenText.zPosition = 15
        screenText.color = UIColor.blackColor()
        screenText.colorBlendFactor = CGFloat(0.0)
        screenText.fontSize = 85
        screenText.text = "TOUCH ANYWHERE TO PLAY!"
        screenText.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height * 0.1)
        self.addChild(screenText)
        
        startGameSound = SKAudioNode(fileNamed: "startGame")
        startGameSound.autoplayLooped = false
        self.addChild(startGameSound)
        
        startGameSound.removeAllActions()
        bgMusic.removeAllActions()
    }
}
