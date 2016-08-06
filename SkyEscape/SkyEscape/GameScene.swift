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
    
    // The scroll version of the nodes will become a scrolling, repeating backround
    
    // Sky View
    var myBackground = SKSpriteNode()
    var myBackgroundScroll = SKSpriteNode()
    
    // Single background mountain
    var mountain = SKSpriteNode()
    var mountainScroll = SKSpriteNode()
    
    // Most foreground mountains
    var ground = SKSpriteNode()
    var groundScroll = SKSpriteNode()
    
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
        myBackground = SKSpriteNode(imageNamed: "cartoonCloudsBG") // Main Background
        mountain = (self.childNodeWithName("mountain") as! SKSpriteNode) // Single mountain
        ground = (self.childNodeWithName("ground") as! SKSpriteNode) // Foreground mountains

        self.physicsWorld.contactDelegate = self // Physics delegate set

        // Animation atlas
        PlaneAtlas = SKTextureAtlas(named:"Images")
        
        for i in 1...PlaneAtlas.textureNames.count { // Iterates loop for plane animation
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
        smokeTrail!.position = CGPointMake(0.0, 0.0)
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
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        // Function for what to do when one node makes contact or collides with another
        let bullet = (contact.bodyA.categoryBitMask == bulletMask) ? contact.bodyA: contact.bodyB
        let other = (bullet == contact.bodyA) ? contact.bodyB: contact.bodyA
        if other.categoryBitMask == starMask {
            self.didHitNode(other)
            // Adds star to make sound
            let star: SKSpriteNode = SKScene(fileNamed: "Star")!.childNodeWithName("star")! as! SKSpriteNode
            star.removeFromParent()
            self.addChild(star)
        }
    }
    
    // Function for collision
    func didHitNode(star: SKPhysicsBody) {
        // The star will emit a spark when hit
        let spark: SKEmitterNode = SKEmitterNode(fileNamed: "Explode")!
        spark.position = star.node!.position
        self.addChild(spark)
        star.node?.removeFromParent()
    
        // Adding sound to the star hits
        self.runAction(SKAction.playSoundFileNamed("star.mp3", waitForCompletion: true))
    }
}
