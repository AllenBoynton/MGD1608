//
//  Tank.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/11/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

// A new class, inheriting from SKSpriteNode and
// adhering to the GameSprite protocol

//class Tank: SKSpriteNode {
//    
//    var enemyTimer = NSTimer()
//    
//    // Spawn enemies
//    var textureAtlas: SKTextureAtlas =
//        SKTextureAtlas(named:"goods.atlas")
//    
//    let tank = SKScene(fileNamed: "Tank")!.childNodeWithName("tank") as! SKSpriteNode
//    
//    // Generate spawning of tank
//    func SpawnTank() {
//        // Generate ground tank - it can't fly!! ;)
//        let minTank = Int(self.size.width / 1.5)
//        let maxTank = Int(self.size.width - 20)
//        let tankSpawnPoint = UInt32(maxTank - minTank)
//        tank.position = CGPoint(x: CGFloat(arc4random_uniform(tankSpawnPoint)), y: self.size.height)
//        
//        tank.removeFromParent()
//        self.addChild(tank)
//        
//        // Set enemy tank spawn intervals
//        enemyTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(Tank.SpawnTank), userInfo: nil, repeats: true)
//        
//        // Add sound
//        tankFiringSound = SKAudioNode(fileNamed: "tankFiring")!
//        tankFiringSound.runAction(SKAction.play())
//        tankFiringSound.autoplayLooped = false
//        
//        self.addChild(tankFiringSound)
//    }
//    // Implement onTap to adhere to the protocol:
//    func onTap() {}
//}
