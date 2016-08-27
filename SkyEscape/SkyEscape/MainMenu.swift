//
//  MainMenu.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/20/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//


import SpriteKit
import AVFoundation

class MainMenu: SKScene {
    
//    var infoButton = SKSpriteNode()
    
    override func didMoveToView(view: SKView) {
        
//        infoButton = SKSpriteNode(imageNamed: "info")
//        infoButton.zPosition = 100
//        infoButton.size = CGSize(width: 30, height: 30)
//        infoButton.position = CGPoint(x: 25, y: 25)
//        infoButton.name = "Info"
        
        // Adds background sound to Main Menu - one time occurance - see no need for pre-load
//        bgMusic = SKAudioNode(fileNamed: "bgMusic")
//        bgMusic.runAction(SKAction.play())
//        bgMusic.autoplayLooped = true
//        self.addChild(bgMusic)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let game: GameScene = GameScene(fileNamed: "GameScene")!
        game.scaleMode = .AspectFit
        let transition: SKTransition = SKTransition.doorsOpenHorizontalWithDuration(3.0)
        self.view?.presentScene(game, transition: transition)
        
//        // Touch screen to play
//        let screenText = SKLabelNode(fontNamed: "guardianpi")
//        screenText.zPosition = 15
//        screenText.color = UIColor.blackColor()
//        screenText.colorBlendFactor = CGFloat(0.0)
//        screenText.fontSize = 80
//        screenText.text = "TOUCH ANYWHERE TO CONTINUE!"
//        screenText.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height * 0.1)
//        self.addChild(screenText)
        
//        bgMusic.runAction(SKAction.pause())
//        startGameSound.removeAllActions()
//        bgMusic.removeAllActions()
    }
}
