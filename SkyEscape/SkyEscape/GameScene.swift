//
//  GameScene.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/3/16.
//  Copyright (c) 2016 Full Sail. All rights reserved.
//

import SpriteKit
import AVFoundation
//import CoreMotion


// Using Swift Operator Overloading - setting functions to fire when and where screen is tapped
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}
func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}
#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif
extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    func normalized() -> CGPoint {
        return self / length()
    }
}

// Binary connections for collision and colliding
struct PhysicsCategory {
    static let ground      : UInt32 = 1  //0x1 << 0
    static let player      : UInt32 = 2  //0x1 << 1
    static let playerWeapon: UInt32 = 3  //0x1 << 2
    static let enemy       : UInt32 = 8  //0x1 << 3
    static let cloud       : UInt32 = 16 //0x1 << 4
    static let starMask    : UInt32 = 16 //0x1 << 4
}
    
// Global emitter objects
var gunfire    : SKEmitterNode!
var smoke      : SKEmitterNode!
var explode    : SKEmitterNode!
var smokeTrail : SKEmitterNode!
var explosion  : SKEmitterNode!
var rain       : SKEmitterNode!

// Global sound
// Audio nodes for sound effects and music
var audioPlayer = AVAudioPlayer()
var bgMusic = SKAudioNode()
var biplaneFlyingSound = SKAudioNode()
var gunfireSound = SKAudioNode()
var starSound = SKAudioNode()
var thumpSound = SKAudioNode()
var thunderSound = SKAudioNode()
var crashSound = SKAudioNode()
var bombSound = SKAudioNode()
var bombDropSound = SKAudioNode()
var planesFightSound = SKAudioNode()
var bGCannonsSound = SKAudioNode()
var planeMGunSound = SKAudioNode()
var tankFiringSound = SKAudioNode()
var airplaneFlyBySound = SKAudioNode()
var airplaneP51Sound = SKAudioNode()


class GameScene: SKScene, SKPhysicsContactDelegate, UIAccelerometerDelegate {
    
    // The scroll version of the nodes will become a scrolling, repeating backround
    
    // Main background
    var myBackground = SKSpriteNode()
    
    // Mid background
    var midground1 = SKSpriteNode()
    var midground2 = SKSpriteNode()
    var mtHeight = CGFloat(200)
    
    // Foreground
    var foreground = SKSpriteNode()
    
    // Nodes for plane animation
    var myPlane = SKSpriteNode()
    var planeArray = [SKTexture]()
    var planeAtlas: SKTextureAtlas =
        SKTextureAtlas(named:"Images")
    
    // Nodes for sky objects
    var star = SKSpriteNode()
    var pulseAnimation = SKAction()
    
    var badCloud = SKSpriteNode()
    var bullet = SKSpriteNode()
    var bomb = SKSpriteNode()
    
    // Enemies
    var enemy1 = SKSpriteNode()
    var enemy2 = SKSpriteNode()
    var enemy3 = SKSpriteNode()
    var tank   = SKSpriteNode()
    var enemyArray: [SKSpriteNode] = []
    var randomEnemy = SKSpriteNode()
    
    // Location for touch screen
    var touchLocation: CGPoint = CGPointZero
//    var motionManager = CMMotionManager()
    
    // Game metering GUI
    var score = 0
    var starCount = 0
    var health = 10
    var gameOver = Bool()
    let maxNumberOfEnemies = 6
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
        // Main Background
        
        // Sets the physics delegate and physics body
        physicsWorld.contactDelegate = self // Physics delegate set
        
        // Adding scrolling background
        myBackground = SKSpriteNode(imageNamed: "cartoonCloudsBGLS")
        createBackground()
        
        // Adding a midground
        midground1 = SKSpriteNode(imageNamed: "mountain")
        midground2 = SKSpriteNode(imageNamed: "mountain")
        createMidground()
        
        // Adding the foreground
        foreground = SKSpriteNode(imageNamed: "lonelytree")
        createForeground()
        
        func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(GameScene.SpawnBullets), userInfo: nil, repeats: false)
        }
        // Adding our player's plane to the scene
        animateMyPlane()
        
        // Spawning stars
        star = SKSpriteNode(imageNamed: "star")
        spawnStars()
        
        // Spawning enemies timer call
        func startEnemyTimer() {
//        enemyTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(GameScene.SpawnSkyEnemy), userInfo: nil, repeats: true)
        }
        
        // Spawning enemy planes
        enemy1 = SKSpriteNode(imageNamed: "enemy1")
        enemy2 = SKSpriteNode(imageNamed: "enemy2")
        enemy3 = SKSpriteNode(imageNamed: "enemy3")
//        SpawnSkyEnemy()
        
        // Initilize values and labels
//        initializeValues()
        
        
        // Created movement of plane by use of accelerometer --------------> Future use!
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
            let sounds = ["Coin", "Hurt", "Powerup", "StartGame", "bgMusic", "biplaneFlying", "gunfire", "star", "thump", "thunder", "crash", "bomb", "bombDrop", "planesFight", "planeMachineGun", "bGCannons", "tankFiring", "airplaneFlyBy", "airplane+p51"]
            for sound in sounds {
                let player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(sound, ofType: "mp3")!))
                player.prepareToPlay()
            }
        } catch {
            print("\(error)")
        }
        
        // Adds background sound to game
        bgMusic = SKAudioNode(fileNamed: "bgMusic")
        bgMusic.runAction(SKAction.play())
        bgMusic.autoplayLooped = false
        
        biplaneFlyingSound = SKAudioNode(fileNamed: "biplaneFlying")
        biplaneFlyingSound.runAction(SKAction.play())
        biplaneFlyingSound.autoplayLooped = false
        
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
            
            /* Allows to tap on screen and plane will present
                at that axis and shoot at point touched*/
            
            myPlane.position.y = location.y // Allows a tap to touch on the y axis
//            myPlane.position.x = location.x // Allows a tap to touch on the x axis
            
            SpawnBullets()
//            bullet.position = myPlane.position
            
            SpawnBombs()
//            bomb.position = myPlane.position
            
            // Determine location to projectile
//            var offset = touchLocation - (bullet.position)
            
            let offset = touchLocation - (bomb.position)
            
            // Escape if you are shooting down or backwards
            if (offset.y < 0) { return }
            
            // Add bullets to scene
//            self.addChild(bullet)
            
            // Abb bombs to scene
//            self.addChild(bomb)
            
            // Get the direction of where to shoot
            let direction = offset.normalized()
            
            // Shoot far enough to be off the screen and node won't count
            let shootDistance = direction * 1000
            
            // Add the shoot amount to the current position
//            var target = shootDistance + bullet.position
            
            _ = shootDistance + bomb.position
            
            // Create the actions
//            let actionMove = SKAction.moveTo(target, duration: 2.0)
//            let actionMoveDone = SKAction.removeFromParent()
//            bullet.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
            
            // Counts number of enemies
//            if let theName = self.nodeAtPoint(location).name {
//                if theName == "Enemy" {
//                    self.removeChildrenInArray([self.nodeAtPoint(location)])
//                    currentNumberOfEnemies-=1
//                    score+=1
//                }
//            }
//            if (gameOver == true){ // If goal is hit - game is completed
//                initializeValues()
//            }
        }
        
        // Starting and stopping background sound
//        bgMusic.runAction(SKAction.pause())
    }
   
    
    /********************************* touchesMoved Function *********************************/
    // MARK: - touchesMoved
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
        
        for touch: AnyObject in touches {
            let location = (touch as! UITouch).locationInNode(self)
            
            // Allows to drag user plane along y axis but not x
            myPlane.position.y = location.y // Allows a tap to touch on the y axis
            myPlane.position.x = location.x
        }
    }
    
    
    /********************************* touchesEnded Function *********************************/
    // MARK: - touchesEnded
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Each node will collide with the equalled item due to bit mask
        // Collision bit map w collisions
        
//        // Bullet collisions
//        bullets.physicsBody?.collisionBitMask = starMask | enemy1Mask | enemy2Mask | enemy3Mask | tankMask
//        
//        // MyPlane collisions
//        myPlane.physicsBody?.collisionBitMask = groundMask | cloudMask | mtMask | missileMask | enemyMask
//        
//        // Which ones react to a collision
//        
//        // Bullet contacts
//        bullets.physicsBody?.contactTestBitMask = bullet.physicsBody!.collisionBitMask | starMask | enemy1Mask | enemy2Mask | enemy3Mask | tankMask | missileMask
//        
//        // MyPlane's contacts
//        myPlane.physicsBody?.contactTestBitMask = myPlane.physicsBody!.collisionBitMask | groundMask | mtMask | enemy1Mask | enemy2Mask | enemy3Mask | tankMask | missileMask | enemyMask
    }
    // Want to use use a double tap or long press to drop bomb
    
    
    /********************************* Update Function *********************************/
    // MARK: - Update Function
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        // Animating midground
        midground1.position = CGPointMake(midground1.position.x - 4, 100)
        midground2.position = CGPointMake(midground2.position.x - 4, midground2.position.y)
        
        if (midground1.position.x < -midground1.size.width + 200 / 2){
            midground1.position = CGPointMake(midground2.position.x + midground2.size.width * 4, mtHeight)
        }
        
        if (midground2.position.x < -midground2.size.width + 200 / 2) {
            midground2.position = CGPointMake(midground1.position.x + midground1.size.width * 4, mtHeight)
        }
        
        if (midground1.position.x < self.frame.width/2) {
            mtHeight = randomNumbers(600, secondNum: 240)
        }
        
        // Planes movement actions by accelerometer ---------------------> Future use!
//        let action1 = SKAction.moveToX(destinationX, duration: 1.0)
//        let action2 = SKAction.moveToY(destinationY, duration: 1.0)
//        let moveAction = SKAction.sequence([action1, action2])
//        MyPlane.runAction(moveAction)
        
        // Adding to gameplay health attributes
//        healthLabel.text = "Health: \(health)"
//        
//        // Changes health label red if too low
//        if(health <= 3) {
//            healthLabel.fontColor = SKColor.redColor()
//        }
//        
//        now = NSDate()
//        if (currentNumberOfEnemies < maxNumberOfEnemies &&
//            now.timeIntervalSince1970 > nextTime.timeIntervalSince1970 &&
//            health > 0) {
//            
//            nextTime = now.dateByAddingTimeInterval(NSTimeInterval(timeBetweenEnemies))
//            enemySpeed = enemySpeed / moveFactor
//            timeBetweenEnemies = timeBetweenEnemies/moveFactor
//        }
//        
//        checkIfPlaneGetsAcross()
//        checkIfGameIsOver()
    }
    
    
    /********************************* didBeginContact *********************************/
    // MARK: - didBeginContact
    
    func didBeginContact(contact: SKPhysicsContact) {
        print("PLANE HAS TAKEOFF")
        
        // Function if bullet hits something
        let bullet = (contact.bodyA.categoryBitMask == PhysicsCategory.playerWeapon) ? contact.bodyA: contact.bodyB
        let bulletOther = (bullet == contact.bodyA) ? contact.bodyB: contact.bodyA
        
        if bulletOther.categoryBitMask == PhysicsCategory.starMask {
            self.didHitStarNode(bulletOther)
        }
        else if bulletOther.categoryBitMask == PhysicsCategory.enemy {
            self.didHitEnemyNode(bulletOther)
        }
        else if bulletOther.categoryBitMask == PhysicsCategory.cloud {
            self.didHitCloudNode(bulletOther)
        }
        
        // If player plane hits something
        let MyPlane = (contact.bodyA.categoryBitMask == PhysicsCategory.player) ? contact.bodyA: contact.bodyB
        let planeOther = (MyPlane == contact.bodyA) ? contact.bodyB: contact.bodyA
        
        if planeOther.categoryBitMask == PhysicsCategory.ground {
            self.didHitGroundNode(planeOther)
        }
        else if planeOther.categoryBitMask == PhysicsCategory.enemy {
            self.didHitEnemyNode(planeOther)
        }
        else if planeOther.categoryBitMask == PhysicsCategory.starMask {
            self.didHitStarNode(planeOther)
        }
        else if planeOther.categoryBitMask == PhysicsCategory.cloud {
            self.didHitCloudNode(planeOther)
        }
        
        // If enemyfire hits something
        let enemyFire = (contact.bodyA.categoryBitMask == PhysicsCategory.enemy) ? contact.bodyA: contact.bodyB
        let other = (enemyFire == contact.bodyA) ? contact.bodyB: contact.bodyA
        
        if other.categoryBitMask == PhysicsCategory.ground {
            self.didHitGroundNode(other)
        }
        else if other.categoryBitMask == PhysicsCategory.enemy {
            self.didHitEnemyNode(other)
        }
        else if other.categoryBitMask == PhysicsCategory.starMask {
            self.didHitStarNode(other)
        }
        else if other.categoryBitMask == PhysicsCategory.cloud {
            self.didHitCloudNode(other)
        }
    }
    
    
    /********************************* Collision Functions *********************************/
    // MARK: - Collision Functions
    
    // Function for collision
    func didHitStarNode(star: SKPhysicsBody) {
        // The star will emit a spark and sound when hit
        explode = SKEmitterNode(fileNamed: "Explode")
        explode.position = star.node!.position
        
        // Adds star to make sound
        star.node?.removeFromParent()
        self.addChild(explode)
        
        // Calling pre-loaded sound to the star hits
        starSound = SKAudioNode(fileNamed: "star")
        starSound.runAction(SKAction.play())
        starSound.autoplayLooped = false
        self.addChild(starSound)
        
        // Points per star added to score
        
    }
    
    // Function for collision with enemy with action and emitter
    func didHitGroundNode(myPlane: SKPhysicsBody) {
        /* Enemy (including ground or obstacle) will 
        emit explosion, smoke and sound when hit*/
        
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        smoke = SKEmitterNode(fileNamed: "Smoke")
        explosion.position = myPlane.node!.position
        smoke.position = myPlane.node!.position
        
        myPlane.node?.removeFromParent()
        self.addChild(explosion)
        self.addChild(smoke)
        
        crashSound = SKAudioNode(fileNamed: "crash")
        crashSound.runAction(SKAction.play())
        crashSound.autoplayLooped = false
        self.addChild(crashSound)
        
        bGCannonsSound = SKAudioNode(fileNamed: "bGCannons")!
        bGCannonsSound.runAction(SKAction.play())
        bGCannonsSound.autoplayLooped = false
        self.addChild(bGCannonsSound)
        
        // Hitting an object loses points off score
        
    }
    
    // Player hit enemy with weapon
    func didHitEnemyNode (enemy: SKPhysicsBody) {
//        explosion = SKEmitterNode(fileNamed: "FireExplosion")
//        smoke = SKEmitterNode(fileNamed: "Smoke")
//        explosion.position = (enemy.node?.position)!
//        smoke.position = enemy.node!.position
        
        badCloud.removeFromParent()
        bullet.removeFromParent()
//        enemy.node?.removeFromParent()
//        self.addChild(explosion)
//        self.addChild(smoke)
        
//        crashSound = SKAudioNode(fileNamed: "crash")
//        crashSound.runAction(SKAction.play())
//        crashSound.autoplayLooped = false
//        self.addChild(crashSound)
        
        bGCannonsSound = SKAudioNode(fileNamed: "bGCannons")
        bGCannonsSound.runAction(SKAction.play())
        bGCannonsSound.autoplayLooped = false
        self.addChild(bGCannonsSound)
    }
    
    // Player hit enemy with weapon
    func didHitCloudNode (cloud: SKPhysicsBody) {
        rain = SKEmitterNode(fileNamed: "Rain")
        rain.position = cloud.node!.position
        rain.position = CGPointMake(badCloud.position.x, badCloud.position.y)
        
        // Influenced by plane's movement
        rain.targetNode = self.scene
        badCloud.addChild(rain)
        
        thunderSound = SKAudioNode(fileNamed: "thump")
        thunderSound.runAction(SKAction.play())
        thumpSound.autoplayLooped = false
        self.addChild(thumpSound)
    }
    
    
    /********************************* Background Functions *********************************/
    // MARK: - Background Functions
    
    // Adding scrolling background
    func createBackground() {
        let myBackground = SKTexture(imageNamed: "cartoonCloudsBGLS")
        
        for i in 0...1 {
            let background = SKSpriteNode(texture: myBackground)
            background.zPosition = 1
            background.anchorPoint = CGPointZero
            background.position = CGPoint(x: (myBackground.size().width * CGFloat(i)) - CGFloat(1 * i), y: 0)
            addChild(background)
            
            let moveLeft = SKAction.moveByX(-myBackground.size().width, y: 0, duration: 30)
            let moveReset = SKAction.moveByX(myBackground.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatActionForever(moveLoop)
            
            background.runAction(moveForever)
        }
    }

    // Adding scrolling midground
    func createMidground() {
        midground1 = SKSpriteNode(imageNamed: "mountain")
        midground1.setScale(3.0)
        midground1.zPosition = 2
        midground1.position = CGPointMake(800, 150)
        midground1.size.height = midground1.size.height
        midground1.size.width = midground1.size.width
        
        // Physics bitmask for mountains
        midground1.physicsBody?.categoryBitMask = PhysicsCategory.ground
        midground1.physicsBody?.contactTestBitMask = PhysicsCategory.player
        
        midground2 = SKSpriteNode(imageNamed: "mountain")
        midground2.position = CGPointMake(1600, 150)
        midground2.setScale(3.0)
        midground2.zPosition = 2
        midground2.size.height = midground2.size.height
        midground2.size.width = midground2.size.width
        
        // Physics bitmask for mountains
        midground2.physicsBody?.categoryBitMask = PhysicsCategory.ground
        midground2.physicsBody?.contactTestBitMask = PhysicsCategory.player
        
        midground1.shadowCastBitMask = 1
        midground2.shadowCastBitMask = 1
        
        // Create physics body
        midground1.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "mountain"), size: midground1.size)
        
        midground2.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "mountain"), size: midground2.size)
        
        midground1.physicsBody?.affectedByGravity = false
        midground2.physicsBody?.affectedByGravity = false
        midground1.physicsBody?.dynamic = false
        midground2.physicsBody?.dynamic = false
        
        self.addChild(midground1)
        self.addChild(midground2)
    }
    
    // RNG for mountain height
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    // Adding scrolling foreground
    func createForeground() {
        
        let foreground = SKTexture(imageNamed: "lonelytree")
        
        for i in 0...1 {
            let ground = SKSpriteNode(texture: foreground)
            ground.zPosition = 3
            ground.position = CGPoint(x: (foreground.size().width / 2 + (foreground.size().width * CGFloat(i))), y: foreground.size().height / 2)
            
            // Create physics body
            ground.physicsBody = SKPhysicsBody(edgeLoopFromRect: ground.frame)
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
            ground.physicsBody?.contactTestBitMask = PhysicsCategory.player
            ground.physicsBody?.dynamic = false
            
            addChild(ground)
            
            let moveLeft = SKAction.moveByX(-foreground.size().width, y: 0, duration: 5)
            let moveReset = SKAction.moveByX(foreground.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatActionForever(moveLoop)
            
            ground.shadowCastBitMask = 1
            
            ground.runAction(moveForever)
        }
    }
    
    
    /********************************* Create/Animate Functions *********************************/
    
    // Animation atlas of MyPlane
    func animateMyPlane() {
        
        for i in 1...planeAtlas.textureNames.count { // Iterates loop for plane animation
            let plane = "myPlane\(i).png"
            planeArray.append(SKTexture(imageNamed: plane))
        }
        
        // Add user's animated bi-plane
        myPlane = SKSpriteNode(imageNamed: planeAtlas.textureNames[0])
        myPlane.setScale(0.2)
        myPlane.zPosition = 6
        myPlane.position = CGPointMake(self.size.width / 5, self.size.height / 2)
        
        // Body physics of player's plane
        myPlane.physicsBody = SKPhysicsBody(rectangleOfSize: myPlane.size)
        myPlane.physicsBody?.affectedByGravity = false
        myPlane.physicsBody?.categoryBitMask = PhysicsCategory.player
        myPlane.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        myPlane.physicsBody?.dynamic = false
        
        // Define and repeat animation
        self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(planeArray, timePerFrame: 0.05)))
        
        self.addChild(myPlane)
        
        addSmokeTrail()
    }
    
    // Add emitter of exhaust smoke behind plane
    func addSmokeTrail() {
        // Create smoke trail for myPlane
        smokeTrail = SKEmitterNode(fileNamed: "SmokeTrail")
        
        //the x & y-position needs to be slightly behind the plane
        smokeTrail.zPosition = 6
        smokeTrail.position = CGPointMake(myPlane.position.x - 200, myPlane.position.y - 75)
        smokeTrail.setScale(3.0)
        
        // Influenced by plane's movement
        smokeTrail.targetNode = self.scene
        self.addChild(smokeTrail)
    }
    
    /********************************* Spawning Functions *********************************/
    // MARK: - Spawn Functions
    
    // Spawn bullets fired
    func SpawnBullets() {
        bullet = SKSpriteNode(imageNamed: "silverBullet")
        bullet.setScale(0.2)
        bullet.zPosition = 7
        
        bullet.position = CGPointMake(myPlane.position.x + 75, myPlane.position.y)

        let action = SKAction.moveToX(self.size.width + 80, duration: 0.5)
        let actionDone = SKAction.removeFromParent()
        bullet.runAction(SKAction.sequence([action, actionDone]))
        
        // Body physics of player's bullets
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.size)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.playerWeapon
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.cloud | PhysicsCategory.starMask
        bullet.physicsBody?.dynamic = false
    
        self.addChild(bullet)
        
        // Add sound to firing
        gunfireSound = SKAudioNode(fileNamed: "gunfire")
        gunfireSound.runAction(SKAction.play())
        gunfireSound.autoplayLooped = false
        self.addChild(gunfireSound)
        
        addGunfireToPlane()
    }
    
    // Add emitter of fire when bullets are fired
    func addGunfireToPlane() {
        // The plane will emit gunfire effect
        gunfire = SKEmitterNode(fileNamed: "Gunfire")!
        
        //the y-position needs to be slightly in front of the plane
        gunfire.setScale(2.5)
        gunfire.zPosition = 20
        gunfire.position = CGPointMake(myPlane.position.x + 110, myPlane.position.y)
        
        // Influenced by plane's movement
//        gunfire.targetNode = self.scene
        self.addChild(gunfire)
    }
    
    // Spawn bombs dropped
    func SpawnBombs() {
        bomb = SKSpriteNode(imageNamed: "bomb1")
        bomb.zPosition = 7
        bomb.setScale(0.2)
        bomb.position = CGPointMake(myPlane.position.x, myPlane.position.y)
        
        // Body physics of player's bullets
        bomb.physicsBody = SKPhysicsBody(rectangleOfSize: bomb.size)
        bomb.physicsBody?.affectedByGravity = true
        bomb.physicsBody?.categoryBitMask = PhysicsCategory.playerWeapon
        bomb.physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.ground
        bomb.physicsBody?.dynamic = false
        
        let action = SKAction.moveToY(self.size.height + 80, duration: 3.0)
        let actionDone = SKAction.removeFromParent()
        bomb.runAction(SKAction.sequence([action, actionDone]))
        
        self.addChild(bomb)
        
        // Adding sound to the cannon fire
        bombSound = SKAudioNode(fileNamed: "bomb")
        bombDropSound = SKAudioNode(fileNamed: "bombDrop")
        bombSound.runAction(SKAction.play())
        bombDropSound.runAction(SKAction.play())
        bombSound.autoplayLooped = false
        bombDropSound.autoplayLooped = false
        
        self.addChild(bombSound)
        self.addChild(bombDropSound)
    }
    
    // Generate spawning of stars - random in 5 sec increments
    func spawnStars() {
        
        star = SKSpriteNode(imageNamed: "star")
        
        star.size = CGSize(width: 40, height: 40)
        star.position = position
        star.zPosition = 6
        star.position = CGPointMake(0, 0)
        star.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        star.physicsBody?.affectedByGravity = false
        star.physicsBody?.categoryBitMask = PhysicsCategory.starMask
        star.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.playerWeapon
        star.physicsBody?.dynamic = true
        
        // Since the star texture is only one frame, set it here:
        star.runAction(pulseAnimation)
        
        self.addChild(star)
        
        createStars()
    }
    
    func createStars() {
        // Scale the star smaller and fade it slightly:
        let pulseOutGroup = SKAction.group([SKAction.fadeAlphaTo(0.85, duration: 0.8), SKAction.scaleTo(0.6, duration: 0.8), SKAction.rotateByAngle(-0.3, duration: 0.8)
            ])
        
        // Push the star big again, and fade it back in:
        let pulseInGroup = SKAction.group([SKAction.fadeAlphaTo(1, duration: 1.5), SKAction.scaleTo(1, duration: 1.5), SKAction.rotateByAngle(3.5, duration: 1.5)
            ])
        
        // Combine the two into a sequence:
        let pulseSequence = SKAction.sequence([pulseOutGroup, pulseInGroup])
        pulseAnimation = SKAction.repeatActionForever(pulseSequence)
    }

    // Spawns an enemy
    func SpawnSkyEnemy() {
        
        // Calculate random spawn points for air enemies
        let minValue = Int(self.size.height / 8)
        let maxValue = Int(self.size.height - 100)
        let spawnPoint = UInt32(maxValue - minValue)
        
        // Generate a random enemy array
        enemyArray = [enemy1, enemy2, enemy3]
        // Generate a random index
        let randomIndex = Int(arc4random_uniform(UInt32(enemyArray.count)))
        // Get a random enemy
        randomEnemy = enemyArray[randomIndex]
        randomEnemy.position = CGPoint(x: self.size.width, y: CGFloat(arc4random_uniform(spawnPoint)))
        randomEnemy.setScale(0.2)
        randomEnemy.zPosition = 10
        randomEnemy.physicsBody?.affectedByGravity = false
        randomEnemy.physicsBody?.collisionBitMask = PhysicsCategory.enemy
        randomEnemy.physicsBody?.contactTestBitMask = PhysicsCategory.player
        randomEnemy.physicsBody?.dynamic = true
        
        // Move enemies forward
        let action = SKAction.moveToX(-50, duration: 3.0)
        let actionDone = SKAction.removeFromParent()
        randomEnemy.runAction(SKAction.sequence([action, actionDone]))
        
        enemy1.removeFromParent()
        enemy2.removeFromParent()
        enemy3.removeFromParent()
        self.addChild(enemy1)
        self.addChild(enemy2)
        self.addChild(enemy3)
        self.addChild(randomEnemy)
        
        // Add sound
        planeMGunSound = SKAudioNode(fileNamed: "planeMachineGun")!
        planeMGunSound.runAction(SKAction.play())
        planeMGunSound.autoplayLooped = false
        
        airplaneFlyBySound = SKAudioNode(fileNamed: "airplaneFlyBy")!
        airplaneFlyBySound.runAction(SKAction.play())
        airplaneFlyBySound.autoplayLooped = false
        
        airplaneP51Sound = SKAudioNode(fileNamed: "airplane+p51")!
        airplaneP51Sound.runAction(SKAction.play())
        airplaneP51Sound.autoplayLooped = false
        
        self.addChild(airplaneP51Sound)
        self.addChild(airplaneFlyBySound)
        self.addChild(planeMGunSound)
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
//        healthLabel.fontSize = 40
//        healthLabel.fontColor = SKColor.blackColor()
//        healthLabel.position = CGPoint(x: frame.minX + 100, y: frame.minY + 40)
//        
//        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
//        scoreLabel.text = "Score: \(score)"
//        scoreLabel.fontSize = 40
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
    
//    // Displays the game over screen
//    func showGameOverScreen(){
//        gameOverLabel = SKLabelNode(fontNamed:"System")
//        gameOverLabel.text = "Game Over! Score: \(score)"
//        gameOverLabel.fontColor = SKColor.redColor()
//        gameOverLabel.fontSize = 65
//        gameOverLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame));
//        self.addChild(gameOverLabel)
//    }
}
