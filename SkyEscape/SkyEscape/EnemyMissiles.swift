//
//  EnemyMissiles.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/11/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

// A new class, inheriting from SKSpriteNode and
// adhering to the GameSprite protocol

//class EnemyMissiles: SKSpriteNode {
//    
//    let myPlane = MyPlane()
//    let tank = Tank()
//    
//    // Spawn enemy missiles
//    var textureAtlas: SKTextureAtlas =
//        SKTextureAtlas(named:"goods.atlas")
//    
//    let missile = SKScene(fileNamed: "Missile")!.childNodeWithName("missile") as! SKSpriteNode
//    
//    // Spawn enemy tank missiles
//    func createMissiles() {
//        missile.zPosition = 6
//        missile.position = CGPointMake(tank.position.x - 80, tank.position.y)
//        
//        // Selecting random y position for missile 
//        let random : CGFloat = CGFloat(arc4random_uniform(300))
//        missile.position = CGPointMake(self.frame.size.width + 50, random)
//        
//        missile.removeFromParent()
//        self.addChild(missile)
//    }
//    // Implement onTap to adhere to the protocol:
//    func onTap() {}
//}
