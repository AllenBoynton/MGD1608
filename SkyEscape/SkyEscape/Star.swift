//
//  Star.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/9/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

// A new class, inheriting from SKSpriteNode and
// adhering to the GameSprite protocol

class Star: SKSpriteNode {
    
    let gameScene = GameScene()
    
    // Power-up pulse animation
    var textureAtlas: SKTextureAtlas =
        SKTextureAtlas(named:"goods.atlas")
    
    var pulseAnimation = SKAction()
    
    // Generate spawning of stars - random in 5 sec increments
    func spawnStars(parentNode: SKNode, position: CGPoint, size: CGSize = CGSize(width: 40, height: 40)) {
        parentNode.addChild(self)
        createStars()
        self.size = size
        self.position = position
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        self.physicsBody?.affectedByGravity = false
        
        // Since the star texture is only one frame, set it here:
        self.texture = textureAtlas.textureNamed("star.png")
        self.runAction(pulseAnimation)
    }
    
    func createStars() {
        // Scale the star smaller and fade it slightly:
        let pulseOutGroup = SKAction.group([SKAction.fadeAlphaTo(0.85, duration: 0.8), SKAction.scaleTo(0.6, duration: 0.8), SKAction.rotateByAngle(-0.3, duration: 0.8)
            ])
        
        // Push the star big again, and fade it back in:
        let pulseInGroup = SKAction.group([SKAction.fadeAlphaTo(1, duration: 1.5), SKAction.scaleTo(1, duration: 1.5), SKAction.rotateByAngle(3.5, duration: 1.5)
            ])
        
        // Combine the two into a sequence:
        let pulseSequence = SKAction.sequence([pulseOutGroup, pulseInGroup])
        pulseAnimation = SKAction.repeatActionForever(pulseSequence)
    }
    
    // Implement onTap to adhere to the protocol:
    func onTap() {}
}
