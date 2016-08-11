//
//  Bomb.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/11/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

// A new class, inheriting from SKSpriteNode and
// adhering to the GameSprite protocol

class Bomb: SKSpriteNode {
    
    let gameScene = GameScene()
    let myPlane = MyPlane()
    
    // Spawn bombs
    var textureAtlas: SKTextureAtlas =
        SKTextureAtlas(named:"goods.atlas")
    
    let bomb = SKScene(fileNamed: "Bomb")!.childNodeWithName("bomb1") as! SKSpriteNode
    
    // Spawn bombs dropped
    func SpawnBombs() {
        bomb.zPosition = 6
        bomb.position = CGPointMake(myPlane.position.x, myPlane.position.y)
        let action = SKAction.moveToY(self.size.height + 30, duration: 3.0)
        bomb.runAction(SKAction.repeatActionForever(action))
        bomb.removeFromParent()
        self.addChild(bomb)
    }
    
    // Implement onTap to adhere to the protocol:
    func onTap() {}
}
