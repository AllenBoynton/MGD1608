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
let mtMask      : UInt32 = 0x1 << 1

let enemy1Mask  : UInt32 = 0x1 << 2 // 4
let enemy2Mask  : UInt32 = 0x1 << 2
let enemy3Mask  : UInt32 = 0x1 << 2
let enemy4Mask  : UInt32 = 0x1 << 2
let tankMask    : UInt32 = 0x1 << 2
let missileMask : UInt32 = 0x1 << 2

let cloudMask   : UInt32 = 0x1 << 3 // 8

let starMask    : UInt32 = 0x1 << 4 // 16

// Emitter global objects
var gunfire = SKEmitterNode()
var smoke = SKEmitterNode()
var explode = SKEmitterNode()
var smokeTrail = SKEmitterNode()
var explosion = SKEmitterNode()


class GameScene: SKScene, SKPhysicsContactDelegate, UIAccelerometerDelegate {
    
    // The scroll version of the nodes will become a scrolling, repeating backround
    
    // Main background texture
    var myBackground = SKTexture()
    
    // All collision nodes
    var star      = SKSpriteNode()
    var badCloud  = SKSpriteNode()
    var bullet    = SKSpriteNode()
    var bomb      = SKSpriteNode()
    var enemyFire = SKSpriteNode()
    var missle    = SKSpriteNode()
    var enemy1    = SKSpriteNode() // Sky enemy
    var enemy2    = SKSpriteNode()
    var enemy3    = SKSpriteNode()
    var tank      = SKSpriteNode() // Ground enemy
    
    // Location for touch screen
    var touchLocation: CGPoint = CGPointZero
    var motionManager = CMMotionManager()
    
    // Audio nodes for sound effects and music
    var bgMusicMusic = SKAudioNode()
    var biplaneFlyingSound = SKAudioNode()
    var gunfireSound = SKAudioNode()
    var starSound = SKAudioNode()
    var thumpSound = SKAudioNode()
    var crashSound = SKAudioNode()
    var bombSound = SKAudioNode()
    var bombDropSound = SKAudioNode()
    var planesFightSound = SKAudioNode()
    var bGCannonsSound = SKAudioNode()
    var planeMGunSound = SKAudioNode()
    var tankFiringSound = SKAudioNode()
    var airplaneFlyBySound = SKAudioNode()
    var airplaneP51Sound = SKAudioNode()
    
    // Nodes for plane animation
    var MyPlane = SKSpriteNode()
    var PlaneAtlas = SKTextureAtlas()
    var PlaneArray = [SKTexture]()
    var PlaneIsActive = Bool(false)
    
    // Calls the sprite to its child node name
    var myMidground1 = SKSpriteNode()
    var myMidground2 = SKSpriteNode()
    var ground1 = SKSpriteNode()
    var ground2 = SKSpriteNode()
    var mtHeight = CGFloat(200)
    
    // Game metering GUI
    var start = false
    var score = 0
    var starCount = 0
    var health = 10
    var gameOver = Bool()
    let maxNumberOfEnemies = 3
    var currentNumberOfEnemies = 0
    var enemySpeed = 5.0
    let moveFactor = 1.0
    var timeBetweenEnemies = 3.0
    var now = NSDate()
    var nextTime = NSDate()
    var healthLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    
    
    /********************************* didMoveToView Function *********************************/
    // MARK: - didMoveToView
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // Calls the sprite to its child node name
        star = (self.childNodeWithName("star") as! SKSpriteNode)
        badCloud = (self.childNodeWithName("badCloud") as! SKSpriteNode)
//        bullet = (self.childNodeWithName("bullet") as! SKSpriteNode)
//        bomb = (self.childNodeWithName("bomb1") as! SKSpriteNode)
//        missle = (self.childNodeWithName("missle") as! SKSpriteNode)
//        enemyFire = (self.childNodeWithName("enemyFire") as! SKSpriteNode)
//        enemy1 = (self.childNodeWithName("Enemy1") as! SKSpriteNode)
//        enemy2 = (self.childNodeWithName("Enemy2") as! SKSpriteNode)
//        enemy3 = (self.childNodeWithName("Enemy3") as! SKSpriteNode)
//        tank = (self.childNodeWithName("Tank") as! SKSpriteNode)

        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsWorld.contactDelegate = self // Physics delegate set
        
        // Initilize values and labels
        initializeValues()

        // Calling func for animated background
        createBackground()
        
        // Adding a midground
        createMidground()
        
        // Adding the foreground
        createForeground()
        
        // Add user's bi-plane
        animateMyPlane()
        
        // Spawning stars
        generateStars()
        
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
        
        // After import AVFoundation, needs do,catch statement to preload sound so no delay
        do {
            let sounds = ["bgMusic", "biplaneFlying", "gunfire", "star", "thump", "crash", "bomb", "bombDrop", "planesFight", "planeMachineGun", "bGCannons", "tankFiring", "mortarRound", "airplaneFlyBy", "airplane+p51"]
            for sound in sounds {
                let player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(sound, ofType: "mp3")!))
                player.prepareToPlay()
            }
        } catch {
            print("\(error)")
        }
        
        // Adds background sound to game
        bgMusicMusic = SKAudioNode(fileNamed: "bgMusic")
        biplaneFlyingSound = SKAudioNode(fileNamed: "biplaneFlying")
        addChild(bgMusicMusic)
        addChild(biplaneFlyingSound)
    }
    
    
    /********************************* touchesBegan Function *********************************/
    // MARK: - touchesBegan
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        touchLocation = touches.first!.locationInNode(self)
        
        // Touch screen to start game
        start = true
        
        // Begin to add impulse to plane
        if (PlaneIsActive) {
            self.MyPlane.physicsBody!.applyImpulse(CGVectorMake(0, 150))
        } else {
            MyPlanePhysics()
        }
        
        // Sets position of bullet at myPlane
        bullet.zPosition = 0
        bullet.position = MyPlane.position
        let angleInRads1 = Float(MyPlane.zRotation)
        let speed1 = CGFloat(50.0)
        let vx1: CGFloat = CGFloat(cosf(angleInRads1)) * speed1
        let vy1: CGFloat = CGFloat(sinf(angleInRads1)) * speed1
        bullet.physicsBody?.applyImpulse(CGVectorMake(vx1, vy1))
        
        // Adds bullet to fire from myPlane
        bullet.removeFromParent()
        MyPlane.addChild(bullet)
        
        // Adds gunfire emitter to plane when firing
        addGunfireToPlane()
        
        // Calling pre-loaded sound to the gun fire
//        gunfireSound = SKAudioNode(fileNamed: "gunfire.mp3")
//        gunfireSound.autoplayLooped = false
//        addChild(gunfireSound)
        
        self.runAction(SKAction.playSoundFileNamed("gunfire.mp3", waitForCompletion: true))
        
        for touch: AnyObject in touches {
            let location = (touch as! UITouch).locationInNode(self)
            if let theName = self.nodeAtPoint(location).name {
                if theName == "Enemy" {
                    self.removeChildrenInArray([self.nodeAtPoint(location)])
                    currentNumberOfEnemies-=1
                    score+=1
                }
            }
            if (gameOver == true){
                initializeValues()
            }
        }
    }
   
    
    /********************************* touchesMoved Function *********************************/
    // MARK: - touchesMoved
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
    }
    
    
    /********************************* touchesEnded Function *********************************/
    // MARK: - touchesEnded
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Each node will collide with the equalled item due to bit mask
        // Collision bit map w collisions
        
        // Bullet collisions
        bullet.physicsBody?.collisionBitMask = starMask | enemy1Mask | enemy2Mask | cloudMask
        
        // MyPlane collisions
        MyPlane.physicsBody?.collisionBitMask = groundMask | cloudMask
        
        // Which ones react to a collision
        
        // Bullet contacts
        bullet.physicsBody?.contactTestBitMask = bullet.physicsBody!.collisionBitMask | starMask | enemy1Mask | enemy2Mask
        
        // MyPlane's contacts
        MyPlane.physicsBody?.contactTestBitMask = MyPlane.physicsBody!.collisionBitMask | groundMask | enemy1Mask | enemy2Mask | enemy3Mask | enemy4Mask | tankMask | missileMask
    }
    
    
    /********************************* Update Function *********************************/
    // MARK: - Update Function
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        // Animating midground
        if (start) {
            
            myMidground1.position = CGPointMake(myMidground1.position.x-8, 200)
            myMidground2.position = CGPointMake(myMidground2.position.x-8, myMidground2.position.y)
            
            if (myMidground1.position.x < -myMidground1.size.width + 600 / 2){
                myMidground1.position = CGPointMake(myMidground2.position.x + myMidground2.size.width * 4, mtHeight)
            }
            
            if (myMidground2.position.x < -myMidground2.size.width + 600 / 2) {
                myMidground2.position = CGPointMake(myMidground1.position.x + myMidground1.size.width * 4, mtHeight)
            }
            
            if (myMidground1.position.x < self.frame.width/2) {
                mtHeight = randomNumbers(100, secondNum: 240)
            }
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
        
        // Planes movement actions by accelerometer
//        let action1 = SKAction.moveToX(destinationX, duration: 1.0)
//        let action2 = SKAction.moveToY(destinationY, duration: 1.0)
//        let moveAction = SKAction.sequence([action1, action2])
//        MyPlane.runAction(moveAction)
        
        MyPlane.position.x = self.frame.width / 2
        
        // Adding to gameplay health attributes
        healthLabel.text = "Health: \(health)"
        
        if(health <= 3) {
            healthLabel.fontColor = SKColor.redColor()
        }
        
        now = NSDate()
        if (currentNumberOfEnemies < maxNumberOfEnemies &&
            now.timeIntervalSince1970 > nextTime.timeIntervalSince1970 &&
            health > 0) {
            
            nextTime = now.dateByAddingTimeInterval(NSTimeInterval(timeBetweenEnemies))
            let newX = Int(arc4random()%1024)
            let newY = Int(self.frame.height+10)
            let p = CGPoint(x: newX, y: newY)
            let destination = CGPoint(x: newX, y: 0)
            
            createEnemy(p, destination: destination)
            
            enemySpeed = enemySpeed / moveFactor
            timeBetweenEnemies = timeBetweenEnemies/moveFactor
        }
        checkIfPlaneGetsAcross()
        checkIfGameIsOver()
    }
    
    
    /********************************* didBeginContact *********************************/
    // MARK: - didBeginContact
    
    func didBeginContact(contact: SKPhysicsContact) {
        print("PLANE HAS TAKEOFF")
        
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
        }
        
        if enemyOther.categoryBitMask == enemy1Mask | enemy2Mask | enemy3Mask | enemy4Mask | tankMask | missileMask {
            
            didHitEnemyNode(enemyOther)
            enemy1 = SKScene(fileNamed: "Enemy1")!.childNodeWithName("enemy1")! as! SKSpriteNode
            enemy2 = SKScene(fileNamed: "Enemy2")!.childNodeWithName("enemy2")! as! SKSpriteNode
            enemy3 = SKScene(fileNamed: "Enemy3")!.childNodeWithName("enemy3")! as! SKSpriteNode
            tank = SKScene(fileNamed: "Tank")!.childNodeWithName("tank")! as! SKSpriteNode
            missle = SKScene(fileNamed: "Missile")!.childNodeWithName("missile")! as! SKSpriteNode
            
            // Enemy reaction
            enemy1.removeFromParent()
            enemy2.removeFromParent()
            enemy3.removeFromParent()
            tank.removeFromParent()
            missle.removeFromParent()
            
            addChild(enemy1)
            addChild(enemy2)
            addChild(enemy3)
            addChild(tank)
            addChild(missle)
        }
        didHitStarNode(starOther)
    }
    
    
    /********************************* Collision Functions *********************************/
    // MARK: - Collision Functions
    
    // Function for collision
    func didHitStarNode(star: SKPhysicsBody) {
        // The star will emit a spark and sound when hit
        explode = SKEmitterNode(fileNamed: "Explode")!
        explode.position = star.node!.position
        
        self.addChild(explode)
        star.node?.removeFromParent()
        
        // Calling pre-loaded sound to the star hits
        starSound = SKAudioNode(fileNamed: "star")!
        addChild(starSound)
        //        self.runAction(SKAction.playSoundFileNamed("star.mp3", waitForCompletion: false))
    }
    
    // Function for collision with enemy with action and emitter
    func didHitGroundNode(MyPlane: SKPhysicsBody) {
        // Enemy (including ground or obstacle) will emit explosion, smoke and sound when hit
        explosion = SKEmitterNode(fileNamed: "FireExplosion")!
        smoke = SKEmitterNode(fileNamed: "Smoke")!
        explosion.position = MyPlane.node!.position
        
        self.addChild(explosion)
        self.addChild(smoke)
        MyPlane.node?.removeFromParent()
        
        crashSound = SKAudioNode(fileNamed: "crash")!
        bGCannonsSound = SKAudioNode(fileNamed: "bGCannons")!
        self.addChild(crashSound)
        self.addChild(bGCannonsSound)
    }
    
    //
    func didHitEnemyNode (enemy: SKPhysicsBody) {
        explosion = SKEmitterNode(fileNamed: "FireExplosion")!
        smoke = SKEmitterNode(fileNamed: "Smoke")!
        explosion.position = MyPlane.position
        
        self.addChild(explosion)
        self.addChild(smoke)
        enemy.node?.removeFromParent()
        
        crashSound = SKAudioNode(fileNamed: "crash")!
        bGCannonsSound = SKAudioNode(fileNamed: "bGCannons")!
        self.addChild(crashSound)
        self.addChild(bGCannonsSound)
    }
    
    
    /********************************* Custom Functions *********************************/
    // MARK: - Custom Functions
    
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
    
    // Adding scrolling midground
    func createMidground() {
        myMidground1 = SKSpriteNode(imageNamed: "mountain")
        myMidground2 = SKSpriteNode(imageNamed: "mountain")
        
        myMidground1.setScale(4.0)
        myMidground1.position = CGPointMake(800, 200)
        myMidground1.size.height = myMidground1.size.height
        myMidground1.size.width = myMidground1.size.width
        
        // Physics bitmask for mountains
        myMidground1.physicsBody?.categoryBitMask = mtMask
        myMidground1.physicsBody?.contactTestBitMask = MyPlaneMask
        
        myMidground2.position = CGPointMake(1600, 200)
        myMidground2.setScale(4.0)
        myMidground2.size.height = myMidground2.size.height
        myMidground2.size.width = myMidground2.size.width
        
        // Physics bitmask for mountains
        myMidground2.physicsBody?.categoryBitMask = mtMask
        myMidground2.physicsBody?.contactTestBitMask = MyPlaneMask
        
        addChild(self.myMidground1)
        addChild(self.myMidground2)
        
        // Create physics body
        myMidground1.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "mountain"), size: self.myMidground1.size)
        
        myMidground2.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "mountain"), size: self.myMidground2.size)
        
        myMidground1.physicsBody?.dynamic = false
        myMidground2.physicsBody?.dynamic = false
    }
    
    // RNG for mountain height
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    // Adding scrolling foreground
    func createForeground() {
        ground1 = SKSpriteNode(imageNamed: "landscape")
        ground2 = SKSpriteNode(imageNamed: "landscape")
        ground1.anchorPoint = CGPointZero;
        ground1.position = CGPointMake(0, 0);
        ground2.anchorPoint = CGPointZero;
        ground2.position = CGPointMake(ground1.size.width-1, 0)
        
        addChild(self.ground1)
        addChild(self.ground2)
        
        // Create physics body
        ground1.physicsBody = SKPhysicsBody(edgeLoopFromRect: ground1.frame)
        ground2.physicsBody = SKPhysicsBody(edgeLoopFromRect: ground1.frame)
    }
    
    // Animation atlas of MyPlane
    func animateMyPlane() {
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
        
        // Create smoke trail for myPlane
        smokeTrail = SKEmitterNode(fileNamed: "SmokeTrail")!
        
        //the x & y-position needs to be slightly behind the plane
        smokeTrail.position = CGPointMake(-175.0, -20.0)
        smokeTrail.xScale = 2.0
        smokeTrail.yScale = 2.0
        
        // Influenced by plane's movement
        smokeTrail.targetNode = self.scene
        MyPlane.addChild(smokeTrail)
    }
    
    // Set physics to myPlane
    func MyPlanePhysics() {
        MyPlane.physicsBody?.linearDamping = 1.1
        MyPlane.physicsBody?.restitution = 0
        
        MyPlane.physicsBody?.categoryBitMask = MyPlaneMask
        MyPlane.physicsBody?.contactTestBitMask = mtMask
        
        PlaneIsActive = true
    }
    
    // Add emitter of fire when bullets are fired
    func addGunfireToPlane() {
        // The plane will emit gunfire effect
        gunfire = SKEmitterNode(fileNamed: "Gunfire")!
        
        //the y-position needs to be slightly in front of the plane
        gunfire.position = MyPlane.position
        gunfire.zPosition = 6
//        gunfire.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
//        gunfire.xScale = 2.0
//        gunfire.yScale = 2.0
        
        // Influenced by plane's movement
        gunfire.targetNode = self.scene
        MyPlane.addChild(gunfire)
    }
    
    // Spawns an enemy
    func createEnemy(p:CGPoint, destination:CGPoint) {
        enemy1 = SKSpriteNode(imageNamed:"enemy1")
        enemy1.name = "ME-109"
        enemy1.position = p
        
        enemy2 = SKSpriteNode(imageNamed:"enemy2")
        enemy2.name = "Swordfish"
        enemy2.position = p
        
        enemy3 = SKSpriteNode(imageNamed:"enemy2")
        enemy3.name = "Typhoon"
        enemy3.position = p
        
        tank = SKSpriteNode(imageNamed:"enemy2")
        tank.name = "T70-300PX"
        tank.position = p
        
        let duration = NSTimeInterval(enemySpeed)
        let action = SKAction.moveTo(destination, duration: duration)
        
        enemy1.runAction(SKAction.repeatActionForever(action))
        enemy2.runAction(SKAction.repeatActionForever(action))
        enemy3.runAction(SKAction.repeatActionForever(action))
        tank.runAction(SKAction.repeatActionForever(action))
        
        currentNumberOfEnemies+=1
        self.addChild(enemy1)
        self.addChild(enemy2)
        self.addChild(enemy3)
        self.addChild(tank)
    }
    
    // Generate spawning of stars - random in 5 sec increments
    func generateStars() {
        let timer = SKAction.waitForDuration(5, withRange: 3)
        let xPos = randomNumbers(0, secondNum: frame.width )
        
        let spawn = SKAction.runBlock {
            let spawnLocation = CGPointMake(CGFloat(xPos), self.frame.size.height/2)
            self.star.position = spawnLocation
        }
        self.addChild(star)
        
        let sequence = SKAction.sequence([timer, spawn])
        self.runAction(SKAction.repeatActionForever(sequence) , withKey: "spawning")
        
        if (self.actionForKey("spawning") != nil){
            return
        }
        
        // Attributes for star to repeat an action
        let degrees = -180.0
        let rads = degrees * M_PI / 180.0
        let action = SKAction.rotateByAngle(CGFloat(rads), duration: 1.0) //Rotation 1way
        star.runAction(SKAction.repeatActionForever(action)) // Runs sequence action forever
    }

    // Sets the initial values for our variables
    func initializeValues(){
        self.removeAllChildren()
        
        score = 0
        gameOver = false
        currentNumberOfEnemies = 0
        timeBetweenEnemies = 1.0
        enemySpeed = 5.0
        health = 10
        nextTime = NSDate()
        now = NSDate()
        
        healthLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        healthLabel.text = "Health: \(health)"
        healthLabel.fontSize = 24
        healthLabel.fontColor = SKColor.blackColor()
        healthLabel.position = CGPoint(x: frame.minX + 20, y: frame.minY + 20)
        
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = SKColor.blackColor()
        scoreLabel.position = CGPoint(x: frame.maxX - 20, y: frame.maxY - 20)
        scoreLabel.horizontalAlignmentMode = .Right
        
        gameOverLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 80
        gameOverLabel.fontColor = SKColor.blackColor()
        gameOverLabel.position = CGPoint(x: CGRectGetMinX(self.frame)/2, y: (CGRectGetMinY(self.frame)/2))
        
        self.addChild(healthLabel)
        self.addChild(scoreLabel)
        self.addChild(gameOverLabel)
    }
    
    // Check if the game is over by looking at our health
    // Shows game over screen if needed
    func checkIfGameIsOver(){
        if (health <= 0 && gameOver == false){
            self.removeAllChildren()
            showGameOverScreen()
            gameOver = true
        }
    }
    
    // Checks if an enemy plane reaches the other side of our screen
    func checkIfPlaneGetsAcross(){
        for child in self.children {
            if(child.position.y == 0){
                self.removeChildrenInArray([child])
                currentNumberOfEnemies-=1
                health -= 1
            }
        }
    }
    
    // Displays the actual game over screen
    func showGameOverScreen(){
        gameOverLabel = SKLabelNode(fontNamed:"System")
        gameOverLabel.text = "Game Over! Score: \(score)"
        gameOverLabel.fontColor = SKColor.redColor()
        gameOverLabel.fontSize = 65;
        gameOverLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(gameOverLabel)
    }
}
