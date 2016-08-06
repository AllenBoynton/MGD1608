//
//  GameScene.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/3/16.
//  Copyright (c) 2016 Full Sail. All rights reserved.
//

import SpriteKit
import AVFoundation

let groundMask  : UInt32 = 0x1 << 0 // 1
let mountainMask: UInt32 = 0x1 << 0

let bulletMask  : UInt32 = 0x1 << 1 // 2
let bombMask    : UInt32 = 0x1 << 1

let enemy1Mask  : UInt32 = 0x1 << 2 // 4
let enemy2Mask  : UInt32 = 0x1 << 2

let cloudMask   : UInt32 = 0x1 << 3 // 8

let starMask    : UInt32 = 0x1 << 4 // 16


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Sky View
    var myBackground = SKSpriteNode()
    var myBackgroundScroll = SKSpriteNode()
    
    // Most foreground mountains
    var ground = SKSpriteNode()
    var groundScroll = SKSpriteNode()
    
    // Single background mountain
    var mountain = SKSpriteNode()
    var mountainScroll = SKSpriteNode()
    
    // All collision nodes
    var star = SKSpriteNode()
    var badCloud = SKSpriteNode()
    var bullet = SKSpriteNode()
    var bomb1 = SKSpriteNode()
    
    // Location for touch screen
    var touchLocation: CGPoint = CGPointZero
    
    // Audio nodes for sound effects and music
    var backgroundMusic = SKAudioNode()
    var planeNoise = SKAudioNode()
    var bulletSound = SKAudioNode()
    var starSound = SKAudioNode()
    
    // Nodes for plane animation
    var MyPlane = SKSpriteNode()
    var PlaneAtlas = SKTextureAtlas()
    var PlaneArray = [SKTexture]()
    
    // Previous frame's time
    var priorFrameTime: NSTimeInterval = 0
    
    // Time since last frame
    var intervalFrameTime: NSTimeInterval = 0
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        // Calls the sprite to its child node name
        star = (self.childNodeWithName("star") as! SKSpriteNode)
        badCloud = (self.childNodeWithName("badCloud") as! SKSpriteNode)
        
        self.physicsWorld.contactDelegate = self // Physics delegate set
        
        // Main Background
        myBackground = SKSpriteNode(imageNamed: "cartoonCloudsBG")
//        myBackground.anchorPoint = CGPointZero
//        myBackground.position = CGPointMake(self.size.width/2, self.size.height/2)
//        self.addChild(myBackground)
//        
//        // Single mountain view background - mid-ground
        mountain = (self.childNodeWithName("mountain") as! SKSpriteNode)
//        mountain.anchorPoint = CGPointZero
//        mountain.position = CGPointMake(500, 0)
//        self.addChild(mountain)
//        
//        // Foreground creation
        ground = (self.childNodeWithName("ground") as! SKSpriteNode)
//        ground.anchorPoint = CGPointZero
//        ground.position = CGPointMake(0, 0)
//        self.addChild(ground)
//        
        // Animation atlas
        PlaneAtlas = SKTextureAtlas(named:"Images")
        
        for i in 1...PlaneAtlas.textureNames.count {
            let Plane = "myPlane\(i).png"
            PlaneArray.append(SKTexture(imageNamed: Plane))
        }
        
        // Set the planes initial position
        MyPlane = SKSpriteNode(imageNamed: PlaneAtlas.textureNames[0])
        
        MyPlane.size = CGSize(width: 350, height: 175)
        MyPlane.position = CGPoint(x: self.size.width / 4, y: self.size.height / 2)
        addChild(MyPlane)
        
        // Define and repeat animation
        MyPlane.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(PlaneArray, timePerFrame: 0.05)))
                
        // Create a smoke trail for plane
        let smokeTrail = SKEmitterNode(fileNamed: "SmokeTrail")
        
        //the y-position needs to be slightly behind the plane
        smokeTrail!.position = CGPointMake(-190.0, -20.0)
        smokeTrail!.xScale = 2.0
        smokeTrail!.yScale = 2.0
        
        // Influenced by plane's movement
        smokeTrail!.targetNode = self.scene
        MyPlane.addChild(smokeTrail!)
        
        // Attributes for star to repeat an action
        let degrees1 = 90.0
        let degrees2 = -90.0
        let rads1 = degrees1 * M_PI / 180.0
        let rads2 = degrees2 * M_PI / 180.0
        let action1 = SKAction.rotateByAngle(CGFloat(rads1), duration: 0.2) //Rotation 1way
        let action2 = SKAction.rotateByAngle(CGFloat(rads2), duration: 0.25) //Rotation opp. way
        let sequence = SKAction.sequence([action1, action2]) // Adds actions together
        star.runAction(SKAction.repeatActionForever(sequence)) // Runs sequence action forever
        
        
        // Adds background sound to game
        let backgroundMusic = SKAudioNode(fileNamed: "bgMusic.mp3")
        let planeNoise = SKAudioNode(fileNamed: "biplaneFlying.mp3")
        addChild(backgroundMusic)
        addChild(planeNoise)
        
        // After import AVFoundation, needs do,catch statement to preload sound so no delay
        do {
            let sounds = ["gunfire", "star"] //, "thump", "crash"]
            for sound in sounds {
                let player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(sound, ofType: "mp3")!))
                player.prepareToPlay()
            }
        } catch {
            print("\(error)")
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        touchLocation = touches.first!.locationInNode(self)
        
        // Adds bomb to drop from myPlane
//                let bomb: SKSpriteNode = SKScene(fileNamed: "Bomb")!.childNodeWithName("bomb")! as! SKSpriteNode
//                bomb.removeFromParent()
//                self.addChild(bomb)
//        
//                // Sets position of bomb at myPlane
//                bomb.zPosition = 0
//                bomb.position = MyPlane.position
//                let angleInRadians2 = Float(MyPlane.zRotation)
//                let speed2 = CGFloat(50.0)
//                let vx2: CGFloat = CGFloat(cosf(angleInRadians2)) * speed2
//                let vy2: CGFloat = CGFloat(sinf(angleInRadians2)) * speed2
//                bomb.physicsBody?.applyImpulse(CGVectorMake(vx2, vy2))
        
        
        let nodes: [AnyObject] = self.nodesAtPoint(touchLocation)
        if nodes == star {
            // Adding sound when star is tapped or flown into
            self.runAction(SKAction.playSoundFileNamed("star.mp3", waitForCompletion: true))
            backgroundMusic.runAction(SKAction.pause())
        }
//        else if nodes == badCloud {
            // Adding sound when star is tapped or flown into
//            self.runAction(SKAction.playSoundFileNamed("thump.mp3", waitForCompletion: false))
//            backgroundMusic.runAction(SKAction.pause())
//            planeNoise.runAction(SKAction.pause())
//            bulletSound.runAction(SKAction.pause())
//        }
//        else if nodes == mountain {
            // Adding sound when star is tapped or flown into
//            self.runAction(SKAction.playSoundFileNamed("crash.mp3", waitForCompletion: false))
//            backgroundMusic.runAction(SKAction.pause())
//            planeNoise.runAction(SKAction.pause())
//            bulletSound.runAction(SKAction.pause())
//        }
        
        // Adding sound to the gun fire
//        self.runAction(SKAction.playSoundFileNamed("gunfire.mp3", waitForCompletion: true))
        
        // Adding sound to the bomb fall
//        self.runAction(SKAction.playSoundFileNamed("bomb.mp3", waitForCompletion: true))
        
//        // Adding sound when star is tapped or flown into
//        self.runAction(SKAction.playSoundFileNamed("star.mp3", waitForCompletion: true))
    }
   
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Adds bullet to fire from myPlane
        let bullet: SKSpriteNode = SKScene(fileNamed: "Bullet")!.childNodeWithName("bullet")! as! SKSpriteNode
        bullet.removeFromParent()
        self.addChild(bullet)
        
        // Sets position of bullet at myPlane
        bullet.zPosition = 0
        bullet.position = MyPlane.position
        let angleInRadians1 = Float(MyPlane.zRotation)
        let speed1 = CGFloat(50.0)
        let vx1: CGFloat = CGFloat(cosf(angleInRadians1)) * speed1
        let vy1: CGFloat = CGFloat(sinf(angleInRadians1)) * speed1
        bullet.physicsBody?.applyImpulse(CGVectorMake(vx1, vy1))
        

        // Each node will collide with the equalled item due to bit mask
        bullet.physicsBody?.collisionBitMask =  starMask
        
        // Which ones react to a collision
        bullet.physicsBody?.contactTestBitMask = bullet.physicsBody!.collisionBitMask | starMask
        
        // Adding sound to the cannon fire
        self.runAction(SKAction.playSoundFileNamed("gunfire.mp3", waitForCompletion: true))
        
        // Starting and stopping background sound
//        backgroundMusic.runAction(SKAction.stop())
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
//        let percent = touchLocation.x / size.width
//        let newAngle = percent * 90 - 90
//        MyPlane.zRotation = CGFloat(newAngle) * CGFloat(M_PI) / 90.0
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let bullet = (contact.bodyA.categoryBitMask == bulletMask) ? contact.bodyA: contact.bodyB
        let other = (bullet == contact.bodyA) ? contact.bodyB: contact.bodyA
        if other.categoryBitMask == starMask {//|| other.categoryBitMask == orangePegMask {
            self.didHitNode(other)
            // Adds star to make sound
            let star: SKSpriteNode = SKScene(fileNamed: "Star")!.childNodeWithName("star")! as! SKSpriteNode
            star.removeFromParent()
            self.addChild(star)
        }
//        else if other.categoryBitMask == squareMask {
//        }
//        else if other.categoryBitMask == wallMask {
//        }
//        else if other.categoryBitMask == ballMask {
//        }
//        else if other.categoryBitMask == bucketMask {
//        }
    }
    
    func didHitNode(star: SKPhysicsBody) {
//        let blue = UIColor(red: 0.16, green: 0.73, blue: 0.78, alpha: 1.0)
//        let orange = UIColor(red: 1.0, green: 0.45, blue: 0.0, alpha: 1.0)
        
        let spark: SKEmitterNode = SKEmitterNode(fileNamed: "Explode")!
        spark.position = star.node!.position
//        spark.particleColor = (peg.categoryBitMask == orangePegMask) ? orange : blue
        self.addChild(spark)
        star.node?.removeFromParent()
    
        // Adding sound to the star hits
        self.runAction(SKAction.playSoundFileNamed("star.mp3", waitForCompletion: true))
    }

}
