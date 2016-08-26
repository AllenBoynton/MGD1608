//
//  InstructionScene.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/23/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit


class InstructionScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        
        // Adds background sound to InstructionScene - one time occurance - see no need for pre-load
        bgMusic = SKAudioNode(fileNamed: "bgMusic.mp3")
        bgMusic.autoplayLooped = true
        self.addChild(bgMusic)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // Brings user back to main menu
        let game: MainMenu = MainMenu(fileNamed: "MainMenu")!
        game.scaleMode = .AspectFill
        let transition: SKTransition = SKTransition.moveInWithDirection(.Down, duration: 2.0)
        self.view?.presentScene(game, transition: transition)
    }

}
