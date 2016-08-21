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
    
    var backgroundMusic = SKAudioNode()
    var infoButton = SKSpriteNode()
    
    override func didMoveToView(view: SKView) {
        
        // Adds background sound to Main Menu - one time occurance - see no need for pre-load
        backgroundMusic = SKAudioNode(fileNamed: "bgMusic.mp3") 
        backgroundMusic.autoplayLooped = true
        self.addChild(backgroundMusic)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let game: GameScene = GameScene(fileNamed: "GameScene")!
        game.scaleMode = .AspectFill
        let transition: SKTransition = SKTransition.doorsOpenVerticalWithDuration(3.0)
        self.view?.presentScene(game, transition: transition)
        backgroundMusic.removeAllActions()
    }
}
