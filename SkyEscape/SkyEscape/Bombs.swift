//
//  Bombs.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/15/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

// A new class, inheriting from SKSpriteNode and
// adhering to the GameSprite protocol

class Bombs: SKSpriteNode, GameSprite {
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named:"weapons.atlas")
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 15, height: 30)) {
        parentNode.addChild(self)
        //        self.setScale(0.2)
        self.size = size
        self.position = position
        self.zPosition = 3
        
        // Body physics of player's bullets
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.collisionBitMask = PhysicsCategory.EnemyFire
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy | PhysicsCategory.StarMask | PhysicsCategory.Cloud | PhysicsCategory.Ground
        self.physicsBody?.dynamic = false
        
        self.texture = textureAtlas.textureNamed("bomb1.png")
        
        // Drop em!
        let action = SKAction.moveToY(self.size.height + 80, duration: 3.0)
        let actionDone = SKAction.removeFromParent()
        self.runAction(SKAction.sequence([action, actionDone]))
        
        // Adding sound
        bombSound = SKAudioNode(fileNamed: "bomb")
        bombDropSound = SKAudioNode(fileNamed: "bombDrop")
        bombSound.runAction(SKAction.play())
        bombDropSound.runAction(SKAction.play())
        bombSound.autoplayLooped = false
        bombDropSound.autoplayLooped = false
        
//        self.addChild(bombSound)
//        self.addChild(bombDropSound)        
    }
    
    // Implement onTap to adhere to the protocol
    func onTap() {}
}

