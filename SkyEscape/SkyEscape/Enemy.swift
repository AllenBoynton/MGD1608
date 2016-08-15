//
//  Enemy.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/15/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

/* A new class, inheriting from SKSpriteNode and
 adhering to the GameSprite protocol */

class Enemy: SKSpriteNode, GameSprite {
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "enemies.atlas")
    
    // Generate ground tank - it can't fly!! ;)
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 200, height: 100)) {
        parentNode.addChild(self)
        self.position = position
        self.size = size
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.collisionBitMask = PhysicsCategory.Enemy
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.MyBullets | PhysicsCategory.Enemy | PhysicsCategory.EnemyFire
        self.physicsBody?.dynamic = true
        
        // Generate a random enemy array
        let textureSprites: [SKTexture] = [
            textureAtlas.textureNamed("enemy1.png"),
            textureAtlas.textureNamed("enemy2.png"),
            textureAtlas.textureNamed("enemy3.png"),
            textureAtlas.textureNamed("enemy4.png")
        ]
        
        // Generate a random index
        let randomIndex = Int(arc4random_uniform(UInt32(textureSprites.count)))
        
        self.texture = textureSprites[randomIndex]
        
        // Move enemies forward
        let action = SKAction.moveToX(self.size.width - 100, duration: 3.5)
        let actionDone = SKAction.removeFromParent()
        self.runAction(SKAction.sequence([action, actionDone]))
                
        // Add sound
        planeMGunSound = SKAudioNode(fileNamed: "planeMachineGun")
        planeMGunSound.runAction(SKAction.play())
        planeMGunSound.autoplayLooped = false
        
        airplaneFlyBySound = SKAudioNode(fileNamed: "airplaneFlyBy")
        airplaneFlyBySound.runAction(SKAction.play())
        airplaneFlyBySound.autoplayLooped = false
        
        airplaneP51Sound = SKAudioNode(fileNamed: "airplane+p51")
        airplaneP51Sound.runAction(SKAction.play())
        airplaneP51Sound.autoplayLooped = false
        
        self.addChild(airplaneP51Sound)
        self.addChild(airplaneFlyBySound)
        self.addChild(planeMGunSound)
    }
    
    // Implement onTap to adhere to the protocol
    func onTap() {}
}
