//
//  EnemyMissiles.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/11/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

/* A new class, inheriting from SKSpriteNode and
 adhering to the GameSprite protocol */

class EnemyMissiles: SKSpriteNode, GameSprite {
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named:"weapons.atlas")
    
    // Spawn enemy tank missiles
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 150, height: 70)) {
        parentNode.addChild(self)
        self.size = size
        self.position = position
        self.zPosition = 6
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.collisionBitMask = PhysicsCategory.EnemyFire
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.MyBullets
        self.physicsBody?.dynamic = true
        
        self.texture = textureAtlas.textureNamed("missile.png")
        
        // Add sound
        tankFiringSound = SKAudioNode(fileNamed: "tankFiring")
        tankFiringSound.runAction(SKAction.play())
        tankFiringSound.autoplayLooped = false
        
        self.addChild(tankFiringSound)
        
        // Selecting random y position for missile 
        let random : CGFloat = CGFloat(arc4random_uniform(300))
        self.position = CGPointMake(self.frame.size.width + 50, random)
 
    }
    
    // Implement onTap to adhere to the protocol:
    func onTap() {}
}
