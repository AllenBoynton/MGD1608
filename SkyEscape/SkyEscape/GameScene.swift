//
//  GameScene.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/3/16.
//  Copyright (c) 2016 Full Sail. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var myBackground: SKSpriteNode!
    var ground1: SKSpriteNode!
    var ground2: SKSpriteNode!
    var mountain: SKSpriteNode!
    var myPlane1: SKSpriteNode!
    var myPlanes: Array<SKTexture>!
    var badCloud: SKSpriteNode!
    var bullet: SKSpriteNode!
    var bomb1: SKSpriteNode!
    var star: SKSpriteNode!
    var touchLocation: CGPoint = CGPointZero
    var backgroundMusic: SKAudioNode!
    var planeNoise: SKAudioNode!
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        // Main Background
        myBackground = SKSpriteNode(imageNamed: "background")
        myBackground.anchorPoint = CGPointZero;
        
        myBackground.position = CGPointMake(100, 0);
        
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
        // Ground views
        ground1 = SKSpriteNode(imageNamed: "ground")
        ground2 = SKSpriteNode(imageNamed: "bgMountain")
        ground1.anchorPoint = CGPointZero;
        ground1.position = CGPointMake(0, 0);
        ground2.anchorPoint = CGPointZero;
        ground2.position = CGPointMake(ground1.size.width-1, 0)
        addChild(self.ground1)
        addChild(self.ground2)
        
        // Nodes objects
        mountain = (self.childNodeWithName("mountain") as! SKSpriteNode)
        myPlane1 = (self.childNodeWithName("myPlane1") as! SKSpriteNode)
        badCloud = (self.childNodeWithName("badCloud") as! SKSpriteNode)
        bullet = (self.childNodeWithName("bullet") as! SKSpriteNode)
        bomb1 = (self.childNodeWithName("bomb1") as! SKSpriteNode)
        star = (self.childNodeWithName("star") as! SKSpriteNode)
        
        self.physicsWorld.contactDelegate = self // Physics delegate set
        
        // Adds background sound to game
        let backgroundMusic = SKAudioNode(fileNamed: "bgMusic.mp3")
        let planeNoise = SKAudioNode(fileNamed: "biplaneFlying.mp3")
        addChild(backgroundMusic)
        addChild(planeNoise)
        
        // After import AVFoundation, needs do,catch statement to preload sound so no delay
        do {
            let sounds = ["gunfire", "ching"]
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
        myPlane1.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
        
        // Adds star to make sound
        let star: SKSpriteNode = SKScene(fileNamed: "Star")?.childNodeWithName("star")! as! SKSpriteNode
        star.removeFromParent()
        self.addChild(star)
        
        // Adding sound to the bomb fall
        self.runAction(SKAction.playSoundFileNamed("ching.mp3", waitForCompletion: true))
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
        bullet.position = myPlane1.position
        let angleInRadians1 = Float(myPlane1.zRotation)
        let speed1 = CGFloat(150.0)
        let vx1: CGFloat = CGFloat(cosf(angleInRadians1)) * speed1
        let vy1: CGFloat = CGFloat(sinf(angleInRadians1)) * speed1
        bullet.physicsBody?.applyImpulse(CGVectorMake(vx1, vy1))
        
        // Adding sound to the gun fire
        self.runAction(SKAction.playSoundFileNamed("gunfire.mp3", waitForCompletion: true))
        
        // Adds bomb to drop from myPlane
//        let bomb1: SKSpriteNode = SKScene(fileNamed: "Bomb1")?.childNodeWithName("bomb1")! as! SKSpriteNode
//        bomb1.removeFromParent()
//        self.addChild(bomb1)
//        
//        // Sets position of bomb at myPlane
//        bomb1.zPosition = 0
//        bomb1.position = myPlane1.position
//        let angleInRadians2 = Float(myPlane1.zRotation)
//        let speed2 = CGFloat(50.0)
//        let vx2: CGFloat = CGFloat(cosf(angleInRadians2)) * speed2
//        let vy2: CGFloat = CGFloat(sinf(angleInRadians2)) * speed2
//        bomb1.physicsBody?.applyImpulse(CGVectorMake(vx2, vy2))
        
        // Starting and stopping background sound
//        backgroundMusic.runAction(SKAction.pause())
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
    }
}
