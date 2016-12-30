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
    
    override func didMove(to view: SKView) {
        
        bgMusic = SKAudioNode(fileNamed: "bgMusic")
        bgMusic.run(SKAction.play())
        bgMusic.autoplayLooped = true
        
        bgMusic.removeFromParent()
        self.addChild(bgMusic)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let game: GameScene = GameScene(fileNamed: "GameScene")!
        game.scaleMode = .aspectFit
        let transition: SKTransition = SKTransition.doorsOpenHorizontal(withDuration: 3.0)
        self.view?.presentScene(game, transition: transition)        
    }
}
