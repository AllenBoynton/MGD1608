//
//  Foreground.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/11/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

// A new class, inheriting from SKSpriteNode and
// adhering to the GameSprite protocol

class Foreground: SKSpriteNode {
    
    let gameScene = GameScene()
    
    // Scroll foreground
    var textureAtlas: SKTextureAtlas =
        SKTextureAtlas(named:"backgrounds.atlas")
    
    let foreground1 = SKScene(fileNamed: "Landscape")!.childNodeWithName("landscape") as! SKSpriteNode
    let foreground2 = SKScene(fileNamed: "Landscape")!.childNodeWithName("landscape") as! SKSpriteNode
    
    // Adding scrolling foreground
    func createForeground() {
        foreground1.anchorPoint = CGPointZero;
        foreground1.position = CGPointMake(0, 0);
        foreground2.anchorPoint = CGPointZero;
        foreground2.position = CGPointMake(foreground1.size.width-1, 0)
        
        self.addChild(foreground1)
        self.addChild(foreground2)
        
        // Create physics body
        foreground1.physicsBody = SKPhysicsBody(edgeLoopFromRect: foreground1.frame)
        foreground2.physicsBody = SKPhysicsBody(edgeLoopFromRect: foreground1.frame)
    }
    

    // Implement onTap to adhere to the protocol:
    func onTap() {}
}
