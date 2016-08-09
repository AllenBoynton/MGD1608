//
//  GameScene.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/3/16.
//  Copyright (c) 2016 Full Sail. All rights reserved.
//

import SpriteKit
import AVFoundation
import CoreMotion

let groundMask  : UInt32 = 0x1 << 0 // 1

let bulletMask  : UInt32 = 0x1 << 1 // 2
let bombMask    : UInt32 = 0x1 << 1
let MyPlaneMask : UInt32 = 0x1 << 1

let enemy1Mask  : UInt32 = 0x1 << 2 // 4
let enemy2Mask  : UInt32 = 0x1 << 2

let cloudMask   : UInt32 = 0x1 << 3 // 8

let starMask    : UInt32 = 0x1 << 4 // 16

// Emitter global objects
var gunfire = SKEmitterNode()
let smoke = SKEmitterNode()
var explode = SKEmitterNode()
var smokeTrail = SKEmitterNode()
var explosion = SKEmitterNode()


class GameScene: SKScene, SKPhysicsContactDelegate, UIAccelerometerDelegate {
    
    // The scroll version of the nodes will become a scrolling, repeating backround
    
    // Location and motion
    var screenRect = CGRect()
    var screenHeight = CGFloat()
    var screenWidth = CGFloat()
    var currentX: CGFloat = 0.0
    var currentY: CGFloat = 0.0
    var destinationX: CGFloat = 0.0
    var destinationY: CGFloat = 0.0
    
    // Main background texture
    var myBackground = SKTexture()
    
    // All collision nodes
    var star = SKSpriteNode()
    var badCloud = SKSpriteNode()
    var bullet = SKSpriteNode()
    var bomb1 = SKSpriteNode()
    var enemy1 = SKSpriteNode() // Sky enemy
    var enemy2 = SKSpriteNode() // Ground enemy
    var landscape = SKSpriteNode() // Ground
    
    // Location for touch screen
    var touchLocation: CGPoint = CGPointZero
    var motionManager = CMMotionManager()
    
    // Audio nodes for sound effects and music
    var backgroundMusic = SKAudioNode()
    var planeNoise = SKAudioNode()
    var bulletSound = SKAudioNode()
    var starSound = SKAudioNode()
    
    // Nodes for plane animation
    var MyPlane = SKSpriteNode()
    var PlaneAtlas = SKTextureAtlas()
    var PlaneArray = [SKTexture]()
    
    // Nodes for missileTruck animation
    var missileTruck = SKSpriteNode()
    var missileTruckAtlas = SKTextureAtlas()
    var missileTruckArray = [SKTexture]()
    
    // Calls the sprite to its child node name
    var myMidground1 = SKSpriteNode()
    var myMidground2 = SKSpriteNode()
    var ground1 = SKSpriteNode()
    var ground2 = SKSpriteNode()
    
    // Game metering GUI
    var score = 0
    var starCount = 0
    var health = 10
    var gameOver : Bool?
    let maxNumberOfShips = 100
    var currentNumberOfShips : Int?
    var timeBetweenShips : Double?
    var moverSpeed = 5.0
    let moveFactor = 1.05
    var now : NSDate?
    var nextTime : NSDate?
    var gameOverLabel : SKLabelNode?
    var healthLabel : SKLabelNode?
    var scoreLabel: SKLabelNode?
    

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // Calls the sprite to its child node name
        star = (self.childNodeWithName("star") as! SKSpriteNode)
        badCloud = (self.childNodeWithName("badCloud") as! SKSpriteNode)

        self.physicsWorld.contactDelegate = self // Physics delegate set

        // Calling func for animated background
        createBackground()
        
        // Adding a midground
        createMidBackground()
        
        // Adding the foreground
        ground1 = SKSpriteNode(imageNamed: "landscape")
        ground2 = SKSpriteNode(imageNamed: "landscape")
        ground1.anchorPoint = CGPointZero
        ground1.position = CGPointMake(0, 0)
        ground2.anchorPoint = CGPointZero
        ground2.position = CGPointMake(ground1.size.width-1, 0)
        
        addChild(self.ground1)
        addChild(self.ground2)
        
        // Animation atlas
        PlaneAtlas = SKTextureAtlas(named:"Images")
        
        for i in 1...PlaneAtlas.textureNames.count { // Iterates loop for plane animation
            let Plane = "myPlane\(i).png"
            PlaneArray.append(SKTexture(imageNamed: Plane))
        }
        
        // Set the planes initial position
        MyPlane = SKSpriteNode(imageNamed: PlaneAtlas.textureNames[0])
        MyPlane.setScale(0.2)
        MyPlane.zPosition = 4
        MyPlane.position = CGPointMake(self.size.width/5, self.size.height/2 )
        addChild(MyPlane)
        
        // Define and repeat animation
        MyPlane.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(PlaneArray, timePerFrame: 0.05)))
        
        // Smoke trail function call
        smokingPlane()
        
//        if motionManager.accelerometerAvailable == true {
//            
//            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { data, error in
//                
//                self.currentX = self.MyPlane.position.x
//                
//                if data!.acceleration.x < 0 {
//                    self.destinationX = self.currentX + CGFloat(data!.acceleration.x * 100.0)
//                } else if data!.acceleration.x > 0 {
//                    self.destinationX = self.currentX + CGFloat(data!.acceleration.x * 100.0)
//                }
//                
//                self.currentY = self.MyPlane.position.y
//                
//                if data!.acceleration.y < 0 {
//                    self.destinationY = self.currentY + CGFloat(data!.acceleration.y * 100.0)
//                } else if data!.acceleration.y > 0 {
//                    self.destinationY = self.currentY + CGFloat(data!.acceleration.y * 100.0)
//                }
//            })
//        }
        
        // Collisions and contact for plane
        MyPlane.physicsBody?.collisionBitMask = groundMask | cloudMask
        MyPlane.physicsBody?.contactTestBitMask = MyPlane.physicsBody!.collisionBitMask | groundMask | enemy1Mask | enemy2Mask
        
        // Attributes for star to repeat an action
        let degrees = -180.0
        let rads = degrees * M_PI / 180.0
        let action = SKAction.rotateByAngle(CGFloat(rads), duration: 1.0) //Rotation 1way
        star.runAction(SKAction.repeatActionForever(action)) // Runs sequence action forever
        
        // Animation atlas for missile truck
        missileTruckAtlas = SKTextureAtlas(named:"Images")
        
        for i in 1...PlaneAtlas.textureNames.count { // Iterates loop for plane animation
            let Plane = "myPlane\(i).png"
            PlaneArray.append(SKTexture(imageNamed: Plane))
        }
        
        // Set the missile truck's initial position
        MyPlane = SKSpriteNode(imageNamed: PlaneAtlas.textureNames[0])
        MyPlane.setScale(0.2)
        MyPlane.zPosition = 4
        MyPlane.position = CGPointMake(self.size.width/5, self.size.height/2 )
        addChild(MyPlane)
        
        // Define and repeat animation
        MyPlane.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(PlaneArray, timePerFrame: 0.05)))
        
        // Adds background sound to game
        backgroundMusic = SKAudioNode(fileNamed: "bgMusic.mp3")
        planeNoise = SKAudioNode(fileNamed: "biplaneFlying.mp3")
        addChild(backgroundMusic)
        addChild(planeNoise)
        
        // After import AVFoundation, needs do,catch statement to preload sound so no delay
        do {
            let sounds = ["gunfire", "star", "thump", "crash"]
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

        // Adds bullet to fire from myPlane
        bullet = SKScene(fileNamed: "Bullet")!.childNodeWithName("bullet")! as! SKSpriteNode
        bullet.removeFromParent()
        self.addChild(bullet)
        
        // Sets position of bullet at myPlane
        bullet.zPosition = 0
        bullet.position = MyPlane.position
        let angleInRads1 = Float(MyPlane.zRotation)
        let speed1 = CGFloat(50.0)
        let vx1: CGFloat = CGFloat(cosf(angleInRads1)) * speed1
        let vy1: CGFloat = CGFloat(sinf(angleInRads1)) * speed1
        bullet.physicsBody?.applyImpulse(CGVectorMake(vx1, vy1))
        bullet.physicsBody?.collisionBitMask = starMask | enemy1Mask | enemy2Mask | cloudMask
        bullet.physicsBody?.contactTestBitMask = bullet.physicsBody!.collisionBitMask | starMask | enemy1Mask | enemy2Mask
        
        // Adds gunfire to plane when firing
        addGunfireToPlane()
        
        // Adding sound to the cannon fire
        self.runAction(SKAction.playSoundFileNamed("gunfire.mp3", waitForCompletion: true))
    }
   
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Each node will collide with the equalled item due to bit mask
        
        
        // Which ones react to a collision
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        // Animating midground
        myMidground1.position = CGPointMake(myMidground1.position.x-2, myMidground1.position.y)
        myMidground2.position = CGPointMake(myMidground2.position.x-2, myMidground2.position.y)
        
        if (myMidground1.position.x < -myMidground1.size.width / 2) {
            myMidground1.position = CGPointMake(myMidground2.position.x + myMidground2.size.width, myMidground1.position.y)
        }
        
        if (myMidground2.position.x < -myMidground2.size.width / 2) {
            myMidground2.position = CGPointMake(myMidground1.position.x + myMidground1.size.width, myMidground2.position.y)
        }
        
        // Animating foreground
        ground1.position = CGPointMake(ground1.position.x-4, ground1.position.y)
        ground2.position = CGPointMake(ground2.position.x-4, ground2.position.y)
        
        if (ground1.position.x < -ground1.size.width / 2) {
            ground1.position = CGPointMake(ground2.position.x + ground2.size.width, ground1.position.y)
        }
        
        if (ground2.position.x < -ground2.size.width / 2) {
            ground2.position = CGPointMake(ground1.position.x + ground1.size.width, ground2.position.y)
        }
        
        // Planes movement actions
        let action1 = SKAction.moveToX(destinationX, duration: 1.0)
        let action2 = SKAction.moveToY(destinationY, duration: 1.0)
        let moveAction = SKAction.sequence([action1, action2])
        MyPlane.runAction(moveAction)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        // Function for what to do when one node makes contact or collides with another
        let bullet = (contact.bodyA.categoryBitMask == bulletMask) ? contact.bodyA: contact.bodyB
        let starOther = (bullet == contact.bodyA) ? contact.bodyB: contact.bodyA
        if starOther.categoryBitMask == starMask {
            didHitStarNode(starOther)
            // Adds star to make sound
            star = SKScene(fileNamed: "Star")!.childNodeWithName("star")! as! SKSpriteNode
            star.removeFromParent()
            addChild(star)
        }
        
        let MyPlane = (contact.bodyA.categoryBitMask == MyPlaneMask) ? contact.bodyA: contact.bodyB
        let groundOther = (MyPlane == contact.bodyA) ? contact.bodyB: contact.bodyA
        let enemyOther = (MyPlane == contact.bodyA) ? contact.bodyB: contact.bodyA
        
        if groundOther.categoryBitMask == groundMask {
            // Ground hit
            didHitGroundNode(groundOther)
            landscape = SKScene(fileNamed: "Landscape")!.childNodeWithName("landscape")! as! SKSpriteNode
            landscape.removeFromParent()
            addChild(landscape)
        }
        
        if enemyOther.categoryBitMask == enemy1Mask | enemy2Mask {
            // Enemy reaction
            enemy1.removeFromParent()
            enemy2.removeFromParent()
            addChild(enemy1)
            addChild(enemy2)
        }
        
    }
    
    // Function for collision
    func didHitStarNode(star: SKPhysicsBody) {
        // The star will emit a spark and sound when hit
        explode = SKEmitterNode(fileNamed: "Explode")!
        explode.position = star.node!.position
        self.addChild(explode)
        star.node?.removeFromParent()
        
        // Adding sound to the star hits
        self.runAction(SKAction.playSoundFileNamed("star.mp3", waitForCompletion: true))
    }
    
    // Function for collision with enemy with action and emitter
    func didHitGroundNode(landscape: SKPhysicsBody) {
        // Enemy (including ground or obstacle) will emit explosion, smoke and sound when hit
        explosion = SKEmitterNode(fileNamed: "FireExplosion")!
        explosion.position = landscape.node!.position
        self.addChild(explosion)
        self.addChild(smoke)
        MyPlane.removeFromParent()
    }
    
    // Adding scrolling background
    func createBackground() {
        myBackground = SKTexture(imageNamed: "cartoonCloudsBG") // Main Background
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: myBackground)
            background.zPosition = -30
            background.anchorPoint = CGPointZero
            background.position = CGPoint(x: (myBackground.size().width * CGFloat(i)) - CGFloat(1 * i), y: 0)
            addChild(background)
            
            // Animation setup for background
            let moveLeft = SKAction.moveByX(-myBackground.size().width, y: 0, duration: 30)
            let moveReset = SKAction.moveByX(myBackground.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatActionForever(moveLoop)
            
            background.runAction(moveForever)
        }
    }

    // Adding scrolling Mid background
    func createMidBackground() {
        myMidground1 = SKSpriteNode(imageNamed: "shrubs1080")
        myMidground2 = SKSpriteNode(imageNamed: "shrubs1080")
        myMidground1.anchorPoint = CGPointZero
        myMidground1.position = CGPointMake(0, 180)
        myMidground2.anchorPoint = CGPointZero
        myMidground2.position = CGPointMake(myMidground1.size.width-1, 180)
        
        addChild(self.myMidground1)
        addChild(self.myMidground2)
    }
    
    // Add emitter of fire when bullets are fired
    func addGunfireToPlane() {
        // The plane will emit gunfire effect
        gunfire = SKEmitterNode(fileNamed: "Gunfire")!
        
        //the y-position needs to be slightly in front of the plane
        gunfire.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        gunfire.xScale = 2.0
        gunfire.yScale = 2.0
        
        // Influenced by plane's movement
        gunfire.targetNode = self.scene
        MyPlane.addChild(gunfire)
    }
    
    func smokingPlane() {
        // Create a smoke trail for plane
        smokeTrail = SKEmitterNode(fileNamed: "SmokeTrail")!
        
        //the x & y-position needs to be slightly behind the plane
        smokeTrail.position = CGPointMake(-175.0, -20.0)
        smokeTrail.xScale = 2.0
        smokeTrail.yScale = 2.0
        
        // Influenced by plane's movement
        smokeTrail.targetNode = self.scene
        MyPlane.addChild(smokeTrail)
    }
    
    func generateEnemies() {
        
        if(self.actionForKey("spawning") != nil){return}
        
        let timer = SKAction.waitForDuration(10)
        
        //let timer = SKAction.waitForDuration(10, withRange: 3)//you can use withRange to randomize duration
        let spawnNode = SKAction.runBlock {
        
            let enemy1 = SKSpriteNode(color: SKColor.greenColor(), size:CGSize(width: 250, height: 175))
            enemy1.name = "enemy" // name it, so you can access all enemies at once.
            
            //spawn enemies inside view's bounds
            let spawnLocation = CGPoint(x:Int(arc4random() % UInt32(self.frame.size.width - enemy1.size.width/2) ),
                y:Int(arc4random() %  UInt32(self.frame.size.height - enemy1.size.width/2)))
            
            enemy1.position = spawnLocation
            self.addChild(enemy1)
            
            print(spawnLocation)
        }
        
        let sequence = SKAction.sequence([timer, spawnNode])
        
        
        self.runAction(SKAction.repeatActionForever(sequence) , withKey: "spawning") // run action with key so you can remove it later
        
        
    }
}
