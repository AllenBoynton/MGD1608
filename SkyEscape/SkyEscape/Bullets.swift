//
//  Bullets.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/15/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

// A new class, inheriting from SKSpriteNode and
// adhering to the GameSprite protocol

class Bullets: SKSpriteNode, GameSprite {
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named:"weapons.atlas")
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 20, height: 20)) {
        parentNode.addChild(self)
//        self.setScale(0.2)
        self.size = size
        self.position = position
        self.zPosition = 3
        
        // Body physics of player's bullets
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.collisionBitMask = PhysicsCategory.MyBullets
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy | PhysicsCategory.StarMask | PhysicsCategory.Cloud
        self.physicsBody?.dynamic = false
        
        self.texture = textureAtlas.textureNamed("silverBullet.png")
        
        // Shoot em up!
        let action = SKAction.moveToX(self.size.width + 100, duration: 0.5)
        let actionDone = SKAction.removeFromParent()
        self.runAction(SKAction.sequence([action, actionDone]))
        
        // Add sound to firing
        gunfireSound = SKAudioNode(fileNamed: "gunfire")
        gunfireSound.runAction(SKAction.play())
        gunfireSound.autoplayLooped = false
        self.addChild(gunfireSound)
    }
    
    // Implement onTap to adhere to the protocol
    func onTap() {}
}
