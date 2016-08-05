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
let bombMask   : UInt32 = 0x1 << 1

let starMask: UInt32 = 0x1 << 2 // 4
let cloudMask: UInt32 = 0x1 << 2

let enemy1Mask: UInt32 = 0x1 << 3 // 8
let enemy2Mask: UInt32 = 0x1 << 3

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var myBackground: SKSpriteNode!
    var ground1: SKSpriteNode!
    var ground2: SKSpriteNode!
    var mountain: SKSpriteNode!
    var touchLocation: CGPoint = CGPointZero
    var backgroundMusic: SKAudioNode!
    var planeNoise: SKAudioNode!
    
    var MyPlane = SKSpriteNode()
    var PlaneAtlas = SKTextureAtlas()
    var PlaneArray = [SKTexture]()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        // Main Background
        myBackground = SKSpriteNode(imageNamed: "background")
        myBackground.anchorPoint = CGPointZero;
        
        myBackground.position = CGPointMake(100, 0);
        
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
//        // Ground views
//        ground1 = SKSpriteNode(imageNamed: "ground")
//        ground2 = SKSpriteNode(imageNamed: "bgMountain")
//        ground1.anchorPoint = CGPointZero;
//        ground1.position = CGPointMake(300, 50);
//        ground2.anchorPoint = CGPointZero;
//        ground2.position = CGPointMake(ground1.size.width-1, 0)
//        addChild(self.ground1)
//        addChild(self.ground2)
        
        // Animation atlas
        PlaneAtlas = SKTextureAtlas(named:"Images")
        
        for i in 1...PlaneAtlas.textureNames.count {
            let Plane = "myPlane\(i).png"
            PlaneArray.append(SKTexture(imageNamed: Plane))
        }
        
        // Set the planes initial position
        MyPlane = SKSpriteNode(imageNamed: PlaneAtlas.textureNames[0])
        
        MyPlane.size = CGSize(width: 350, height: 175)
        MyPlane.position = CGPoint(x: self.size.width / 6, y: self.size.height / 2)
        self.addChild(MyPlane)
        
        // Nodes objects
        mountain = (self.childNodeWithName("mountain") as! SKSpriteNode)
//        MyPlane = (self.childNodeWithName("myPlane1") as! SKSpriteNode)
        
        // Adds background sound to game
        let backgroundMusic = SKAudioNode(fileNamed: "bgMusic.mp3")
        let planeNoise = SKAudioNode(fileNamed: "biplaneFlying.mp3")
        addChild(backgroundMusic)
        addChild(planeNoise)
        
        // After import AVFoundation, needs do,catch statement to preload sound so no delay
        do {
            let sounds = ["gunfire"] //, "star"]
            for sound in sounds {
                let player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(sound, ofType: "mp3")!))
                player.prepareToPlay()
            }
        } catch {
            print("\(error)")
        }
        
        self.physicsWorld.contactDelegate = self // Physics delegate set
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        touchLocation = touches.first!.locationInNode(self)
//        MyPlane.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
        
        // Define and repeat animation
        MyPlane.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(PlaneArray, timePerFrame: 0.1)))
        
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
        
        
        // Adds star to make sound
//        let star: SKSpriteNode = SKScene(fileNamed: "Star")!.childNodeWithName("star")! as! SKSpriteNode
//        star.removeFromParent()
//        self.addChild(star)
        
        
        // Adds bomb to drop from myPlane
//        let bomb: SKSpriteNode = SKScene(fileNamed: "Bomb")!.childNodeWithName("bomb")! as! SKSpriteNode
//        bomb.removeFromParent()
//        self.addChild(bomb)
//        
//        // Sets position of bomb at myPlane
//        bomb.zPosition = 0
//        bomb.position = MyPlane.position
//        let angleInRadians2 = Float(MyPlane.zRotation)
//        let speed2 = CGFloat(50.0)
//        let vx2: CGFloat = CGFloat(cosf(angleInRadians2)) * speed2
//        let vy2: CGFloat = CGFloat(sinf(angleInRadians2)) * speed2
//        bomb.physicsBody?.applyImpulse(CGVectorMake(vx2, vy2))
        
        
        // Adding sound to the gun fire
        self.runAction(SKAction.playSoundFileNamed("gunfire.mp3", waitForCompletion: true))
        
        // Adding sound to the bomb fall
        self.runAction(SKAction.playSoundFileNamed("star.mp3", waitForCompletion: true))
        
        // Adding sound to the bomb fall
        self.runAction(SKAction.playSoundFileNamed("star.mp3", waitForCompletion: true))
    }
   
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Starting and stopping background sound
//        backgroundMusic.runAction(SKAction.pause())
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
    }
}
