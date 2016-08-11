//
//  MyPlane.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/8/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

// A new class, inheriting from SKSpriteNode and
// adhering to the GameSprite protocol

class MyPlane: SKSpriteNode {
    
    let gameScene = GameScene()
    let myPlane = MyPlane()
    
    // Nodes for plane animation
    var textureAtlas: SKTextureAtlas =
        SKTextureAtlas(named:"Images.atlas")
    
    var PlaneTexture: SKTexture?
    
    var MyPlane = SKSpriteNode()
    var PlaneArray = [SKTexture]()
    var PlaneIsActive = Bool(false)
    
    // Animation atlas of MyPlane
    func animateMyPlane() {
        textureAtlas = SKTextureAtlas(named:"Images")
        
        for i in 1...textureAtlas.textureNames.count { // Iterates loop for plane animation
            let Plane = "myPlane\(i).png"
            PlaneArray.append(SKTexture(imageNamed: Plane))
        }
        
        // Set the planes initial position
        MyPlane = SKSpriteNode(imageNamed: textureAtlas.textureNames[0])
        MyPlane.setScale(0.2)
        MyPlane.zPosition = 6
        MyPlane.position = CGPointMake(self.size.width / 5, self.size.height / 2 )
        self.addChild(MyPlane)
        
        // Define and repeat animation
        MyPlane.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(PlaneArray, timePerFrame: 0.05)))
        
        addSmokeTrail()
    }
    
    // Add emitter of exhaust smoke behind plane
    func addSmokeTrail() {
        // Create smoke trail for myPlane
        smokeTrail = SKEmitterNode(fileNamed: "SmokeTrail")!
        
        //the x & y-position needs to be slightly behind the plane
        smokeTrail.zPosition = 6
        smokeTrail.position = CGPointMake(myPlane.position.x - 120, myPlane.position.y - 25)
        smokeTrail.setScale(2.0)
        
        // Influenced by plane's movement
        smokeTrail.targetNode = self.scene
        self.addChild(smokeTrail)
    }
    
    // Set physics to myPlane
    func MyPlanePhysics() {
        MyPlane.physicsBody?.linearDamping = 1.1
        MyPlane.physicsBody?.restitution = 0
        
        MyPlane.physicsBody?.categoryBitMask = MyPlaneMask
        MyPlane.physicsBody?.contactTestBitMask = mtMask
        
        PlaneIsActive = true
    }
    
    // Implement onTap to adhere to the protocol:
    func onTap() {}
}
