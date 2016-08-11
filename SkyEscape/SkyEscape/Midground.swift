//
//  Midground.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/11/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

// A new class, inheriting from SKSpriteNode and
// adhering to the GameSprite protocol

class Midground: SKSpriteNode {
    
    let gameScene = GameScene()
    
    // Scroll midground
    var textureAtlas: SKTextureAtlas =
        SKTextureAtlas(named:"backgrounds.atlas")
    
    let midground1 = SKScene(fileNamed: "Mountain")!.childNodeWithName("mountain") as! SKSpriteNode
    let midground2 = SKScene(fileNamed: "Mountain")!.childNodeWithName("mountain") as! SKSpriteNode

    // Adding scrolling midground
    func createMidground() {
        self.texture = textureAtlas.textureNamed("mountain.png")
        midground1.setScale(6.0)
        midground1.position = CGPointMake(800, 600)
        midground1.size.height = midground1.size.height
        midground1.size.width = midground1.size.width
        
        // Physics bitmask for mountains
        midground1.physicsBody?.categoryBitMask = mtMask
        midground1.physicsBody?.contactTestBitMask = MyPlaneMask
        
        midground2.position = CGPointMake(1600, 600)
        midground2.setScale(6.0)
        midground2.size.height = midground2.size.height
        midground2.size.width = midground2.size.width
        
        self.addChild(midground1)
        self.addChild(midground2)
        
        // Physics bitmask for mountains
        midground2.physicsBody?.categoryBitMask = mtMask
        midground2.physicsBody?.contactTestBitMask = MyPlaneMask
        
        midground1.shadowCastBitMask = 1
        midground2.shadowCastBitMask = 1
        
        // Create physics body
        midground1.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "mountain"), size: midground1.size)
        
        midground2.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "mountain"), size: midground2.size)
        
        midground1.physicsBody?.dynamic = false
        midground2.physicsBody?.dynamic = false
    }
    
    // RNG for mountain height
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    // Implement onTap to adhere to the protocol:
    func onTap() {}
}
