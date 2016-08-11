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
let mtMask      : UInt32 = 0x1 << 0

let bulletMask  : UInt32 = 0x1 << 1 // 2
let bombMask    : UInt32 = 0x1 << 1
let enemyMask   : UInt32 = 0x1 << 1
let missileMask : UInt32 = 0x1 << 1

let MyPlaneMask : UInt32 = 0x1 << 2 // 4
let enemy1Mask  : UInt32 = 0x1 << 2
let enemy2Mask  : UInt32 = 0x1 << 2
let enemy3Mask  : UInt32 = 0x1 << 2
let tankMask    : UInt32 = 0x1 << 2

let cloudMask   : UInt32 = 0x1 << 3 // 8

let starMask    : UInt32 = 0x1 << 4 // 16

// Emitter global objects
var gunfire    : SKEmitterNode!
var smoke      : SKEmitterNode!
var explode    : SKEmitterNode!
var smokeTrail : SKEmitterNode!
var explosion  : SKEmitterNode!


class GameScene: SKScene, SKPhysicsContactDelegate, UIAccelerometerDelegate {
    
    // The scroll version of the nodes will become a scrolling, repeating backround
    
    // Main background texture
    var myBackground: SKTexture!
    
    // Calls the sprite a scene object
    var myMidground1 = SKSpriteNode()
    var myMidground2 = SKSpriteNode()
    var ground1 = SKSpriteNode()
    var ground2 = SKSpriteNode()
    var mtHeight = CGFloat(200)
    
    // Nodes for plane animation
    var MyPlane = SKSpriteNode()
    var PlaneAtlas = SKTextureAtlas()
    var PlaneArray = [SKTexture]()
    var PlaneIsActive = Bool(false)
    
    // Makes sprite an object
    var star      : SKSpriteNode! // Sky objects
    var badCloud  : SKSpriteNode!
    
    var bullet    : SKSpriteNode! // Fire power
    var bomb      : SKSpriteNode!
    var missile   : SKSpriteNode!
    var enemyFire : SKSpriteNode!
    
    var enemy1    : SKSpriteNode! // Enemies
    var enemy2    : SKSpriteNode!
    var enemy3    : SKSpriteNode!
    var tank      : SKSpriteNode!
    let enemyArray: [SKSpriteNode] = []
    
    // Location for touch screen
    var touchLocation: CGPoint = CGPointZero
    var motionManager = CMMotionManager()
    
    // Audio nodes for sound effects and music
    var bgMusic = SKAudioNode()
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
    
    // Game metering GUI
//    var start = false
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
    var timer = NSTimer()
    var enemyTimer = NSTimer()
    var nextTime = NSDate()
    var healthLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    
    
    /********************************* didMoveToView Function *********************************/
    // MARK: - didMoveToView
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // Calls the sprite to its child node name
        badCloud = (self.childNodeWithName("badCloud") as! SKSpriteNode)
//        enemyFire = (self.childNodeWithName("enemyFire") as! SKSpriteNode)
        
        // Calls the sprite from its custom scene file
        star.removeFromParent()
        star = SKScene(fileNamed: "Star")!.childNodeWithName("star") as! SKSpriteNode
        bullet = SKScene(fileNamed: "Bullet")!.childNodeWithName("bullet") as! SKSpriteNode
//        bomb = SKScene(fileNamed: "Bomb")!.childNodeWithName("bomb1") as! SKSpriteNode
//        missile = SKScene(fileNamed: "Missile")!.childNodeWithName("missile")! as! SKSpriteNode
        ground1 = SKScene(fileNamed: "Landscape")!.childNodeWithName("landscape") as! SKSpriteNode
        ground2 = SKScene(fileNamed: "Landscape")!.childNodeWithName("landscape") as! SKSpriteNode
        enemy1  = SKScene(fileNamed: "Enemy1")!.childNodeWithName("enemy1") as! SKSpriteNode
        enemy2  = SKScene(fileNamed: "Enemy2")!.childNodeWithName("enemy2") as! SKSpriteNode
        enemy3  = SKScene(fileNamed: "Enemy3")!.childNodeWithName("enemy3") as! SKSpriteNode
        tank    = SKScene(fileNamed: "Tank")!.childNodeWithName("tank") as! SKSpriteNode

        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsWorld.contactDelegate = self // Physics delegate set
        
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
        
        // Initilize values and labels
//        initializeValues()
        
        // Set enemy spawn intervals
        enemyTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(GameScene.SpawnSkyEnemy), userInfo: nil, repeats: true)
        enemyTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(GameScene.SpawnTank), userInfo: nil, repeats: true)
        
        // Created movement of plane by use of accelerometer
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
            let sounds = ["bgMusic", "biplaneFlying", "gunfire", "star", "thump", "crash", "bomb", "bombDrop", "planesFight", "planeMachineGun", "bGCannons", "tankFiring", "airplaneFlyBy", "airplane+p51"]
            for sound in sounds {
                let player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(sound, ofType: "mp3")!))
                player.prepareToPlay()
            }
        } catch {
            print("\(error)")
        }

        // Adds background sound to game
        bgMusic = SKAudioNode(fileNamed: "bgMusic")
        biplaneFlyingSound = SKAudioNode(fileNamed: "biplaneFlying")
        addChild(bgMusic)
        addChild(biplaneFlyingSound)
    }
    
    
    /********************************* touchesBegan Function *********************************/
    // MARK: - touchesBegan
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        touchLocation = touches.first!.locationInNode(self)
        
        for touch: AnyObject in touches {
            let location = (touch as! UITouch).locationInNode(self)
            
            MyPlane.position.y = location.y // Allows a tap to touch on the y axis
            MyPlane.position.x = location.x
            
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
        
        self.runAction(SKAction.playSoundFileNamed("gunfire.mp3", waitForCompletion: true))
        
        // Starting and stopping background sound
        bgMusic.runAction(SKAction.pause())
    }
   
    
    /********************************* touchesMoved Function *********************************/
    // MARK: - touchesMoved
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
        
        for touch: AnyObject in touches {
            let location = (touch as! UITouch).locationInNode(self)
            
            MyPlane.position.y = location.y // Allows a tap to touch on the y axis
            MyPlane.position.x = location.x
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
    
    
    /********************************* touchesEnded Function *********************************/
    // MARK: - touchesEnded
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Each node will collide with the equalled item due to bit mask
        // Collision bit map w collisions
        
        // Bullet collisions
        bullet.physicsBody?.collisionBitMask = starMask | enemy1Mask | enemy2Mask | enemy3Mask | tankMask
        
        // MyPlane collisions
        MyPlane.physicsBody?.collisionBitMask = groundMask | cloudMask | mtMask | missileMask | enemyMask
        
        // Which ones react to a collision
        
        // Bullet contacts
        bullet.physicsBody?.contactTestBitMask = bullet.physicsBody!.collisionBitMask | starMask | enemy1Mask | enemy2Mask | enemy3Mask | tankMask | missileMask
        
        // MyPlane's contacts
        MyPlane.physicsBody?.contactTestBitMask = MyPlane.physicsBody!.collisionBitMask | groundMask | mtMask | enemy1Mask | enemy2Mask | enemy3Mask | tankMask | missileMask | enemyMask
    }
    
    
    /********************************* Update Function *********************************/
    // MARK: - Update Function
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        // Animating midground
        myMidground1.position = CGPointMake(myMidground1.position.x - 4, 400)
        myMidground2.position = CGPointMake(myMidground2.position.x - 4, myMidground2.position.y)
        
        if (myMidground1.position.x < -myMidground1.size.width + 400 / 2){
            myMidground1.position = CGPointMake(myMidground2.position.x + myMidground2.size.width * 4, mtHeight)
        }
        
        if (myMidground2.position.x < -myMidground2.size.width + 400 / 2) {
            myMidground2.position = CGPointMake(myMidground1.position.x + myMidground1.size.width * 4, mtHeight)
        }
        
        if (myMidground1.position.x < self.frame.width/2) {
            mtHeight = randomNumbers(400, secondNum: 240)
        }
        
        // Animating foreground
        ground1.position = CGPointMake(ground1.position.x - 6, ground1.position.y)
        ground2.position = CGPointMake(ground2.position.x - 6, ground2.position.y)
        
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
        
        // Function if bullet hits something
        let bullet = (contact.bodyA.categoryBitMask == bulletMask) ? contact.bodyA: contact.bodyB
        let bulletOther = (bullet == contact.bodyA) ? contact.bodyB: contact.bodyA
        
        if bulletOther.categoryBitMask == starMask {
            self.didHitStarNode(bulletOther)
        }
        else if bulletOther.categoryBitMask == enemy1Mask | enemy2Mask | enemy3Mask | tankMask | missileMask {
            self.didHitEnemyNode(bulletOther)
        }
        else if bulletOther.categoryBitMask == cloudMask {
            self.didHitCloudNode(bulletOther)
        }
        
        // If player plane hits something
        let MyPlane = (contact.bodyA.categoryBitMask == MyPlaneMask) ? contact.bodyA: contact.bodyB
        let planeOther = (MyPlane == contact.bodyA) ? contact.bodyB: contact.bodyA
        
        if planeOther.categoryBitMask == groundMask | mtMask {
            self.didHitGroundNode(planeOther)
        }
        else if planeOther.categoryBitMask == enemy1Mask | enemy2Mask | enemy3Mask | tankMask | missileMask | enemyMask {
            self.didHitEnemyNode(planeOther)
        }
        else if planeOther.categoryBitMask == starMask {
            self.didHitStarNode(planeOther)
        }
        else if planeOther.categoryBitMask == cloudMask {
            self.didHitCloudNode(planeOther)
        }
        
        // If enemyfire hits something
        let enemyFire = (contact.bodyA.categoryBitMask == enemyMask) ? contact.bodyA: contact.bodyB
        let other = (enemyFire == contact.bodyA) ? contact.bodyB: contact.bodyA
        
        if other.categoryBitMask == groundMask {
            self.didHitGroundNode(other)
        }
        else if other.categoryBitMask == enemy1Mask | enemy2Mask | enemy3Mask | tankMask | missileMask {
            self.didHitEnemyNode(other)
        }
        else if other.categoryBitMask == starMask {
            self.didHitStarNode(other)
        }
        else if other.categoryBitMask == cloudMask {
            self.didHitCloudNode(other)
        }
        
    }
    
    
    /********************************* Collision Functions *********************************/
    // MARK: - Collision Functions
    
    // Function for collision
    func didHitStarNode(star: SKPhysicsBody) {
        // The star will emit a spark and sound when hit
        explode = SKEmitterNode(fileNamed: "Explode")!
        explode.position = star.node!.position
        
        // Adds star to make sound
        star.node?.removeFromParent()
        self.addChild(explode)
        
        // Calling pre-loaded sound to the star hits
        starSound = SKAudioNode(fileNamed: "star")!
        starSound.autoplayLooped = false
        self.addChild(starSound)
        
        // Points per star added to score
        
    }
    
    // Function for collision with enemy with action and emitter
    func didHitGroundNode(MyPlane: SKPhysicsBody) {
        // Enemy (including ground or obstacle) will emit explosion, smoke and sound when hit
        explosion = SKEmitterNode(fileNamed: "FireExplosion")!
        smoke = SKEmitterNode(fileNamed: "Smoke")!
        explosion.position = MyPlane.node!.position
        explosion.position = MyPlane.node!.position
        
        MyPlane.node?.removeFromParent()
        self.addChild(explosion)
        self.addChild(smoke)
        
        crashSound = SKAudioNode(fileNamed: "crash")!
        crashSound.autoplayLooped = false
        self.addChild(crashSound)
        
        bGCannonsSound = SKAudioNode(fileNamed: "bGCannons")!
        bGCannonsSound.autoplayLooped = false
        self.addChild(bGCannonsSound)
        
        // Hitting an object loses points off score
        
    }
    
    // Player hit enemy with weapon
    func didHitEnemyNode (enemy: SKPhysicsBody) {
        explosion = SKEmitterNode(fileNamed: "FireExplosion")!
        smoke = SKEmitterNode(fileNamed: "Smoke")!
        explosion.position = enemy.node!.position
        smoke.position = enemy.node!.position
        
        enemy.node?.removeFromParent()
        self.addChild(explosion)
        self.addChild(smoke)
        
        crashSound = SKAudioNode(fileNamed: "crash")!
        crashSound.autoplayLooped = false
        self.addChild(crashSound)
        
        bGCannonsSound = SKAudioNode(fileNamed: "bGCannons")!
        bGCannonsSound.autoplayLooped = false
        self.addChild(bGCannonsSound)
    }
    
    // Player hit enemy with weapon
    func didHitCloudNode (cloud: SKPhysicsBody) {
        smoke = SKEmitterNode(fileNamed: "Smoke")!
        smoke.position = cloud.node!.position
        
        self.addChild(smoke)
        
        thumpSound = SKAudioNode(fileNamed: "thump")!
        thumpSound.autoplayLooped = false
        self.addChild(thumpSound)
    }
    
    /********************************* Custom Functions *********************************/
    // MARK: - Custom Functions
    
    // Adding scrolling background
    func createBackground() {
        myBackground = SKTexture(imageNamed: "cartoonCloudsBG") // Main Background
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: myBackground)
            background.zPosition = 0
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
        
        myMidground1.setScale(6.0)
        myMidground1.position = CGPointMake(800, 600)
        myMidground1.size.height = myMidground1.size.height
        myMidground1.size.width = myMidground1.size.width
        
        // Physics bitmask for mountains
        myMidground1.physicsBody?.categoryBitMask = mtMask
        myMidground1.physicsBody?.contactTestBitMask = MyPlaneMask
        
        myMidground2.position = CGPointMake(1600, 600)
        myMidground2.setScale(6.0)
        myMidground2.size.height = myMidground2.size.height
        myMidground2.size.width = myMidground2.size.width
        
        addChild(self.myMidground1)
        addChild(self.myMidground2)
        
        // Physics bitmask for mountains
        myMidground2.physicsBody?.categoryBitMask = mtMask
        myMidground2.physicsBody?.contactTestBitMask = MyPlaneMask
        
        myMidground1.shadowCastBitMask = 1
        myMidground2.shadowCastBitMask = 1
        
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
        
        self.addChild(ground1)
        self.addChild(ground2)
        
        // Create physics body
        ground1.physicsBody = SKPhysicsBody(edgeLoopFromRect: ground1.frame)
        ground2.physicsBody = SKPhysicsBody(edgeLoopFromRect: ground1.frame)
    }
    
    // Animation atlas of MyPlane
    func animateMyPlane() {
        PlaneAtlas = SKTextureAtlas(named:"Images")
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(GameScene.SpawnBullets), userInfo: nil, repeats: true)
        
        for i in 1...PlaneAtlas.textureNames.count { // Iterates loop for plane animation
            let Plane = "myPlane\(i).png"
            PlaneArray.append(SKTexture(imageNamed: Plane))
        }
        
        // Set the planes initial position
        MyPlane = SKSpriteNode(imageNamed: PlaneAtlas.textureNames[0])
        MyPlane.setScale(0.2)
        MyPlane.zPosition = 6
        MyPlane.position = CGPointMake(self.size.width / 5, self.size.height / 2 )
        self.addChild(MyPlane)
        
        // Define and repeat animation
        MyPlane.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(PlaneArray, timePerFrame: 0.05)))
        
        // Create smoke trail for myPlane
        smokeTrail = SKEmitterNode(fileNamed: "SmokeTrail")!
        
        //the x & y-position needs to be slightly behind the plane
        smokeTrail.zPosition = 6
        smokeTrail.position = CGPointMake(MyPlane.position.x - 120, MyPlane.position.y - 25)
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
    
    // Spawn bullets fired
    func SpawnBullets() {
        bullet.zPosition = 6
        bullet.position = CGPointMake(MyPlane.position.x + 75, MyPlane.position.y)
        let action = SKAction.moveToX(self.size.width + 30, duration: 50.0)
        bullet.runAction(SKAction.repeatActionForever(action))
        bullet.removeFromParent()
        self.addChild(bullet)
        
        addGunfireToPlane()
    }
    
    // Spawn bombs dropped
//    func SpawnBombs() {
//        bomb.zPosition = 6
//        bomb.position = CGPointMake(MyPlane.position.x, MyPlane.position.y)
//        let action = SKAction.moveToY(self.size.height + 30, duration: 3.0)
//        bomb.runAction(SKAction.repeatActionForever(action))
//        bomb.removeFromParent()
//        self.addChild(bomb)
//    }
    
    // Add emitter of fire when bullets are fired
    func addGunfireToPlane() {
        // The plane will emit gunfire effect
        gunfire = SKEmitterNode(fileNamed: "Gunfire")!
        
        //the y-position needs to be slightly in front of the plane
        gunfire.zPosition = 6
        gunfire.position = CGPointMake(MyPlane.position.x + 75, MyPlane.position.y)
        gunfire.setScale(1.5)
        
        // Influenced by plane's movement
        gunfire.targetNode = self.scene
        self.addChild(gunfire)
    }
    
    // Spawns an enemy
    func SpawnSkyEnemy() {
        // Calculate random spawn points for air enemies
        let minValue = Int(self.size.height / 8)
        let maxValue = -30
        let spawnPoint = UInt32(maxValue - minValue)
        
        // Generate a random enemy selector
        let enemyArray = [enemy1, enemy2, enemy3]
        // Generate a random index
        let randomIndex = Int(arc4random_uniform(UInt32(enemyArray.count)))
        // Get a random enemy
        let randomEnemy = enemyArray[randomIndex]
        randomEnemy.position = CGPoint(x: self.size.width, y: CGFloat(arc4random_uniform(spawnPoint)))
        randomEnemy.removeFromParent()
        self.addChild(randomEnemy)
    }
    
    // Generate spawning of tank
    func SpawnTank() {
        // Generate ground tank - it can't fly!! ;)
        let minTank = Int(self.size.width / 1.5)
        let maxTank = Int(self.size.width - 20)
        let tankSpawnPoint = UInt32(maxTank - minTank)
        tank.position = CGPoint(x: CGFloat(arc4random_uniform(tankSpawnPoint)), y: self.size.height)
        tank.removeFromParent()
        self.addChild(tank)
    }
    
    // Generate spawning of stars - random in 5 sec increments
    func generateStars() {
        // will stop spawning depending on numb created
        if (self.actionForKey("spawning") != nil){
            return
        }
        
        let timer = SKAction.waitForDuration(5)
        let xPos = randomNumbers(0, secondNum: frame.width)
        
        let spawn = SKAction.runBlock {
            let spawnLocation = CGPointMake(CGFloat(xPos), self.frame.size.height / 2)
            self.star.position = spawnLocation
        }
        star.removeFromParent()
        self.addChild(star)
        self.addChild(star)
        self.addChild(star)
        
        let sequence = SKAction.sequence([timer, spawn])
        star.runAction(SKAction.repeatActionForever(sequence) , withKey: "spawning")
        
        // Attributes for star to repeat an action
        let degrees = -180.0
        let rads = degrees * M_PI / 180.0
        let action = SKAction.rotateByAngle(CGFloat(rads), duration: 1.0) //Rotation 1way
        star.runAction(SKAction.repeatActionForever(action)) // Runs sequence action forever
    }

    // Sets the initial values for our variables
//    func initializeValues(){
//        self.removeAllChildren()
//        
//        score = 0
//        gameOver = false
//        currentNumberOfEnemies = 0
//        timeBetweenEnemies = 1.0
//        enemySpeed = 5.0
//        health = 10
//        nextTime = NSDate()
//        now = NSDate()
//        
//        healthLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
//        healthLabel.text = "Health: \(health)"
//        healthLabel.fontSize = 30
//        healthLabel.fontColor = SKColor.blackColor()
//        healthLabel.position = CGPoint(x: frame.minX + 100, y: frame.minY + 40)
//        
//        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
//        scoreLabel.text = "Score: \(score)"
//        scoreLabel.fontSize = 30
//        scoreLabel.fontColor = SKColor.blackColor()
//        scoreLabel.position = CGPoint(x: frame.maxX - 100, y: frame.maxY - 40)
//        scoreLabel.horizontalAlignmentMode = .Right
//        
//        gameOverLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
//        gameOverLabel.text = "GAME OVER"
//        gameOverLabel.fontSize = 80
//        gameOverLabel.fontColor = SKColor.blackColor()
//        gameOverLabel.position = CGPoint(x: CGRectGetMinX(self.frame)/2, y: (CGRectGetMinY(self.frame)/2))
//        
//        self.addChild(healthLabel)
//        self.addChild(scoreLabel)
//        self.addChild(gameOverLabel)
//    }
    
    // Check if the game is over by looking at our health
    // Shows game over screen if needed
//    func checkIfGameIsOver(){
//        if (health <= 0 && gameOver == false){
//            self.removeAllChildren()
//            showGameOverScreen()
//            gameOver = true
//        }
//    }
    
    // Checks if an enemy plane reaches the other side of our screen
//    func checkIfPlaneGetsAcross(){
//        for child in self.children {
//            if(child.position.x == 0){
//                self.removeChildrenInArray([child])
//                currentNumberOfEnemies-=1
//                health -= 1
//            }
//        }
//    }
    
    // Displays the game over screen
//    func showGameOverScreen(){
//        gameOverLabel = SKLabelNode(fontNamed:"System")
//        gameOverLabel.text = "Game Over! Score: \(score)"
//        gameOverLabel.fontColor = SKColor.redColor()
//        gameOverLabel.fontSize = 65;
//        gameOverLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
//        self.addChild(gameOverLabel)
//    }
}
