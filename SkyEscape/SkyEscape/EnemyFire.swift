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

class EnemyFire: SKSpriteNode {
    
    // Spawn enemyfire
//    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named:"goods")
//    
//    let enemyFire = SKSpriteNode(imageNamed: "bullet")
//    
//    // Spawn bullets fired
//    func createEnemyFire() {
//        enemyFire.zPosition = 6
//        enemyFire.position = CGPointMake(randomEnemy.position.x - 75, randomEnemy.position.y)
//        let action = SKAction.moveToX(self.size.width + 50, duration: 0.1)
//        enemyFire.runAction(SKAction.repeatActionForever(action))
//        
//        enemyFire.removeFromParent()
//        self.addChild(enemyFire)
//        
//        // Add sound to enemy planes firing
//        
//        addGunfireToPlane()
//    }
//    
//    // Add emitter of fire when bullets are fired
//    func addGunfireToPlane() {
//        // The plane will emit gunfire effect
//        gunfire = SKEmitterNode(fileNamed: "Gunfire")!
//        
//        //the y-position needs to be slightly in front of the plane
//        gunfire.zPosition = 8
//        gunfire.position = CGPointMake(randomEnemy.position.x - 75, randomEnemy.position.y)
//        gunfire.setScale(1.5)
//        
//        // Influenced by plane's movement
//        gunfire.targetNode = self.scene
//        gunfire.removeFromParent()
//        self.addChild(gunfire)
//        
//        // Add sounds
//        planesFightSound = SKAudioNode(fileNamed: "planesFight")!
//        planesFightSound.runAction(SKAction.play())
//        planesFightSound.autoplayLooped = false
//        
//        self.addChild(planesFightSound)
//    }
    // Implement onTap to adhere to the protocol:
    func onTap() {}
}
