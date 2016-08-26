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
    
    var infoButton = SKSpriteNode()
    
    override func didMoveToView(view: SKView) {
        
        infoButton = SKSpriteNode(imageNamed: "info")
        infoButton.zPosition = 100
        infoButton.size = CGSize(width: 30, height: 30)
        infoButton.position = CGPoint(x: 25, y: 25)
        
        // Add scene and info button
//        let bgScene = SKSpriteNode(imageNamed: "skyEscape")
//        bgScene.zPosition = 0
//        bgScene.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
//        bgScene.size = self.frame.size
//        self.addChild(bgScene)
        
        // Add game title text
//        let titleLabel = SKLabelNode(fontNamed: "guardianpi")
//        titleLabel.zPosition = 10
//        titleLabel.text = "SKY\nESCAPE"
//        titleLabel.fontSize = 150
//        titleLabel.fontColor = SKColor.blackColor()
//        titleLabel.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height * 0.75)
//        self.addChild(titleLabel)
        
        // Add decorative line between 2 word title
//        let titleLine = SKSpriteNode()
//        titleLine.zPosition = 10
//        titleLine.color = UIColor.blackColor()
//        titleLine.colorBlendFactor = CGFloat(0.0)
//        titleLine.position = CGPoint(x: titleLabel.frame.size.width + 20, y: titleLabel.frame.size.height / 2 + 5)
//        titleLine.size = CGSize(width: titleLabel.frame.size.width + 20, height: 4.0)
//        self.addChild(titleLine)
        
//        // Adds background sound to Main Menu - one time occurance - see no need for pre-load
//        bgMusic = SKAudioNode(fileNamed: "bgMusic.mp3") 
//        bgMusic.autoplayLooped = true
//        self.addChild(bgMusic)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let game: GameScene = GameScene(fileNamed: "GameScene")!
        game.scaleMode = .AspectFill
        let transition: SKTransition = SKTransition.doorsOpenVerticalWithDuration(3.0)
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
