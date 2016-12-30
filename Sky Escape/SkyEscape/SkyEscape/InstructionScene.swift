//
//  InstructionScene.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/23/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit
import AVFoundation


class InstructionScene: SKScene {
    
    override func didMove(to view: SKView) {
        
        bGCannonsSound = SKAudioNode(fileNamed: "bgCannons")
        bGCannonsSound.run(SKAction.play())
        bGCannonsSound.autoplayLooped = true
        
        bGCannonsSound.removeFromParent()
        self.addChild(bGCannonsSound)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Brings user back to main menu
        let game: GameScene = GameScene(fileNamed: "GameScene")!
        game.scaleMode = .aspectFit
        let transition: SKTransition = SKTransition.doorsOpenVertical(withDuration: 3.0)
        self.view?.presentScene(game, transition: transition)
    }
}
