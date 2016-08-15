//
//  Coins.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/9/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

class Coins: SKSpriteNode, GameSprite {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"goods.atlas")
    // Store a value for the bronze coin:
    var value = 1
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 26, height: 26)) {
        parentNode.addChild(self)
        self.size = size
        self.position = position
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        self.physicsBody?.affectedByGravity = false
        self.texture = textureAtlas.textureNamed("coin-bronze.png")
    }
    
    // A function to transform this coin into gold!
    func turnToGold() {
        self.texture = textureAtlas.textureNamed("coin-gold.png")
        self.value = 5
    }
    
    // Implement onTap to adhere to the protocol
    func onTap() {}
}
