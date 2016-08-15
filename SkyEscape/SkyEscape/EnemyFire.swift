//
//  EnemyFire.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/11/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

// A new class, inheriting from SKSpriteNode and
// adhering to the GameSprite protocol

class EnemyFire: SKSpriteNode, GameSprite {
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named:"weapons.atlas")
    
    // Spawn enemy tank missiles
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 20, height: 20)) {
        parentNode.addChild(self)
        self.size = size
        self.position = position
        self.zPosition = 3
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.collisionBitMask = PhysicsCategory.EnemyFire
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.MyBullets
        self.physicsBody?.dynamic = false
        
        self.texture = textureAtlas.textureNamed("enemyFire.png")
        
        let action = SKAction.moveToX(self.size.width + 100, duration: 0.5)
        let actionDone = SKAction.removeFromParent()
        self.runAction(SKAction.sequence([action, actionDone]))
    }
    
    // Implement onTap to adhere to the protocol
    func onTap() {}
}
