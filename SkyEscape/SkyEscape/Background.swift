//
//  Background.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/11/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

// A new class, inheriting from SKSpriteNode and
// adhering to the GameSprite protocol

class Background: SKSpriteNode {
    
    let gameScene = GameScene()
    
    // Scroll background
    var textureAtlas: SKTextureAtlas =
        SKTextureAtlas(named:"backgrounds.atlas")
    
    var myBackground: SKTexture?
    
    // Adding scrolling background
    func createBackground() {
        myBackground = SKTexture(imageNamed: "cartoonCloudsBGLS") // Main Background
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: myBackground)
            background.zPosition = 0
            background.anchorPoint = CGPointZero
            background.position = CGPoint(x: (myBackground!.size().width * CGFloat(i)) - CGFloat(1 * i), y: 0)
            addChild(background)
            
            // Animation setup for background
            let moveLeft = SKAction.moveByX(-myBackground!.size().width, y: 0, duration: 30)
            let moveReset = SKAction.moveByX(myBackground!.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatActionForever(moveLoop)
            
            background.runAction(moveForever)
        }
    }
    
    // Implement onTap to adhere to the protocol:
    func onTap() {}
}
