//
//  InstructionScene.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/23/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit


class InstructionScene: SKScene {
    
    let infoLabel = SKLabelNode()
    
    override func didMoveToView(view: SKView) {
        
        // Instructions label
        infoLabel.fontName = (fontNamed: "gaurdianpi")
        infoLabel.fontSize = 24
        infoLabel.fontColor = SKColor.blackColor()
        infoLabel.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        infoLabel.zPosition = 15
        infoLabel.text = "Instructions:\n\nIf screen tilt feature is available, tilt the screen in the direction that you want your plane to go.\n\nTap the screen to shoot bullets straight ahead of you.\n\nShoot or run over with your plane the Power Up Hearts to gain health.\n\nShoot or run down with your plane the coins to add coins to your pocket for upgrades.\n\nDirect collisions with enemy planes or the ground will cause immediate death!\n\nBeing shot by enemy planes will decrease your health. When your health is down to 25% your health meter will turn red.\n\nYou can check your assets in the heads up display at the top of the screen.\n\nTo pause your game, simply tap the blue pause button in the top center.\n\nThe game is over once you kill 20 planes or you die!!\n\nEnjoy the game!!"
        self.addChild(infoLabel)
        
        // Adds background sound to InstructionScene - one time occurance - see no need for pre-load
        bgMusic = SKAudioNode(fileNamed: "bgMusic.mp3")
        bgMusic.autoplayLooped = true
        self.addChild(bgMusic)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // Brings user back to main menu
        let game: GameScene = GameScene(fileNamed: "GameScene")!
        game.scaleMode = .AspectFill
        let transition: SKTransition = SKTransition.doorsOpenVerticalWithDuration(3.0)
        self.view?.presentScene(game, transition: transition)
    }

}
