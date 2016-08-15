//
//  Player.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/8/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

class Player : SKSpriteNode, GameSprite {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named: "Images.atlas")
    
    // Local variables to help animate flight upwards and downwards
    var flyUpAnimation = SKAction()
    var flyDownAnimation = SKAction()
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 200, height: 100)) {
        parentNode.addChild(self)
        self.size = size
        self.position = position
        self.zPosition = 3
        
        // If we run an action with a key, "flapAnimation",
        // we can later reference that key to remove the action.
        self.runAction(flyUpAnimation, withKey: "flyingAnimation")
        
        // Body physics of player's plane
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.Player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy | PhysicsCategory.Ground | PhysicsCategory.EnemyFire
        self.physicsBody?.dynamic = false
        self.physicsBody = SKPhysicsBody(texture: textureAtlas.textureNamed("myPlane2.png"), size: size)
        
        // Create a physics body based on one frame
        let bodyTexture = textureAtlas.textureNamed("myPlane2.png")
        
        self.physicsBody = SKPhysicsBody(texture: bodyTexture, size: size)
        
        // Increase momentum
        self.physicsBody?.linearDamping = 0.9
        // Average bi-planes weigh around 100 kg
        self.physicsBody?.mass = 100
        // No rotation
        self.physicsBody?.allowsRotation = false
        
        createAnimations()
        addSmokeTrail()
    }
    
    func createAnimations() {
        // Allows rotation with up/down movement
        let tiltUpAction = SKAction.rotateToAngle(0, duration: 0.475)
        tiltUpAction.timingMode = .EaseOut
        let tiltDownAction = SKAction.rotateToAngle(-1, duration: 0.8)
        tiltDownAction.timingMode = .EaseIn
        
        // Create the flying animation
        var textureSprites = [SKTexture]()
        
        for i in 1...textureAtlas.textureNames.count { // Iterates loop for plane animation
            let plane = "myPlane\(i).png"
            textureSprites.append(SKTexture(imageNamed: plane))
        }
        
        // Define and repeat animation
        let flyAction = SKAction.animateWithTextures(textureSprites, timePerFrame: 0.05)
        
        // Including the flying animation frames with the rotation up
        flyUpAnimation = SKAction.group([SKAction.repeatActionForever(flyAction), tiltUpAction])
        
        // Create the decent
        let decentFrames:[SKTexture] = [textureAtlas.textureNamed("myPlane2.png")]
        let downAction = SKAction.animateWithTextures(decentFrames, timePerFrame: 1)
        
        // Group the decent with the rotation down:
        flyDownAnimation = SKAction.group([SKAction.repeatActionForever(downAction), tiltDownAction])

//        self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textureSprites, timePerFrame: 0.1)))
    }
    
    // Add emitter of exhaust smoke behind plane
    func addSmokeTrail() {
        // Create smoke trail for myPlane
        smokeTrail = SKEmitterNode(fileNamed: "SmokeTrail")
        
        //the x & y-position needs to be slightly behind the plane
        smokeTrail.zPosition = 3
        smokeTrail.position = CGPointMake(self.position.x - 200, self.position.y - 75)
        smokeTrail.setScale(3.0)
        
        // Influenced by plane's movement
        smokeTrail.targetNode = self.scene
        self.addChild(smokeTrail)
    }
    
    func update() {}
    
    func onTap() {}
}