//
//  MyPlane.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/21/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

//import SpriteKit


//class MyPlane: SKSpriteNode {

//    var myPlane: SKSpriteNode!
//    var flyingPlaneFrames: [SKTexture]!
//    var flyAnimation = SKAction()
//    
//    // Create player's plane
//    func createPlane() {
//        
//        let planeAtlas = SKTextureAtlas(named: "Airplanes")
//        var flyFrames = [SKTexture]()
//        
//        let numImages = planeAtlas.textureNames.count
//        for i in 1...numImages {
//            let fokkerTextureName = "Fokker_attack_\(i)"
//            flyFrames.append(planeAtlas.textureNamed(fokkerTextureName))
//        }
//        
//        flyingPlaneFrames = flyFrames
//        
//        let firstFrame = flyingPlaneFrames[0]
//        myPlane = SKSpriteNode(texture: firstFrame)
////        myPlane.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
//        myPlane.name = "MyPlane"
//        myPlane.zPosition = 11
//        myPlane.position = CGPoint(x: self.size.width / 6, y: self.size.height / 2)
//        myPlane.runAction(flyAnimation)
//        
//        // Body physics of player's plane
//        myPlane.physicsBody?.categoryBitMask = PhysicsCategory.MyPlane
//        myPlane.physicsBody?.collisionBitMask = PhysicsCategory.Enemy | PhysicsCategory.Ground | PhysicsCategory.EnemyFire | PhysicsCategory.SkyBombs
//        myPlane.physicsBody?.contactTestBitMask = myPlane.physicsBody!.collisionBitMask | PhysicsCategory.Ground | PhysicsCategory.Enemy | PhysicsCategory.EnemyFire | PhysicsCategory.SkyBombs | PhysicsCategory.Star
//        
//        myPlane.physicsBody?.dynamic = false
//        myPlane.physicsBody?.affectedByGravity = false
//        
//        self.addChild(myPlane)
//        
//        // Create the animation
//        let flyAction = SKAction.animateWithTextures(flyFrames, timePerFrame: 0.2)
//        flyAnimation = SKAction.repeatActionForever(flyAction)
//    }
//}