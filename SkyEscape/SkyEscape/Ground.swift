//
//  Ground.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/9/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

// A new class, inheriting from SKSpriteNode and
// adhering to the GameSprite protocol.

class Ground: SKSpriteNode, GameSprite {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"ground.atlas")
    
    // Create an optional property named groundTexture to store
    // the current ground texture:
    var groundTexture: SKTexture?
    
    func spawn(parentNode:SKNode, position:CGPoint, size:CGSize) {
        parentNode.addChild(self)
        self.size = size
        self.position = position
        
        /* Placing the foreground just slightly above the bottom 
        of the screen, will better fit on any of screen size. */
        self.anchorPoint = CGPointMake(0, 1)
        
        // Draw an edge physics body along the top of the ground node.
        // Note: physics body positions are relative to their nodes.
        // The top left of the node is X: 0, Y: 0, given our anchor point.
        // The top right of the node is X: size.width, Y: 0
        let pointTopRight = CGPoint(x: size.width, y: 0)
        self.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointZero, toPoint: pointTopRight)
        
        if groundTexture == nil {
            groundTexture = textureAtlas.textureNamed("lonelytree.png")
        }
        
        self.texture = groundTexture
        
        // Created child nodes to repeat the ground
        createGroundNodes()
    }
    
    // Build child nodes to repeat the ground texture
    func createGroundNodes() {
        if let texture = groundTexture {
            var groundCount: CGFloat = 0
            let textureSize = texture.size()
            
            // Creates a proportional scene...not distorted
            let groundSize = CGSize(width: textureSize.width / 2, height: textureSize.height / 2)
            
            // Making sure the ground covers the entire bottom
            while groundCount * groundSize.width < self.size.width {
                let groundNode = SKSpriteNode(texture: texture)
                groundNode.size = groundSize
                groundNode.position.x = groundCount * groundSize.width
                
                // Position the ground by its upper corner
                groundNode.anchorPoint = CGPoint(x: 0, y: 1)
                
                // Add the child texture to the ground node:
                self.addChild(groundNode)
                
                groundCount++
            }
        }
    }
    
    func onTap() {}
}
