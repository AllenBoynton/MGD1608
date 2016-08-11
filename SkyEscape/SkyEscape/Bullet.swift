//
//  Bullet.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/11/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

// A new class, inheriting from SKSpriteNode and
// adhering to the GameSprite protocol

class Bullet: SKSpriteNode {
    
    let gameScene = GameScene()
    let myPlane = MyPlane()
    
    // Spawn bullets
    var textureAtlas: SKTextureAtlas =
        SKTextureAtlas(named:"goods.atlas")
    
    let bullet = SKScene(fileNamed: "Bullet")!.childNodeWithName("bullet") as! SKSpriteNode
    
    // Spawn bullets fired
    func SpawnBullets() {
        bullet.zPosition = 6
        bullet.position = CGPointMake(myPlane.position.x + 75, myPlane.position.y)
        let action = SKAction.moveToX(self.size.width + 30, duration: 50.0)
        bullet.runAction(SKAction.repeatActionForever(action))
        bullet.removeFromParent()
        self.addChild(bullet)
        
        addGunfireToPlane()
    }
    
    // Add emitter of fire when bullets are fired
    func addGunfireToPlane() {
        // The plane will emit gunfire effect
        gunfire = SKEmitterNode(fileNamed: "Gunfire")!
        
        //the y-position needs to be slightly in front of the plane
        gunfire.zPosition = 6
        gunfire.position = CGPointMake(myPlane.position.x + 75, myPlane.position.y)
        gunfire.setScale(1.5)
        
        // Influenced by plane's movement
        gunfire.targetNode = self.scene
        self.addChild(gunfire)
    }
    

    // Implement onTap to adhere to the protocol:
    func onTap() {}
}
