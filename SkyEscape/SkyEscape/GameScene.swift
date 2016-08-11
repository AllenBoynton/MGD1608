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


// Access other swift texture files
protocol GameSprite {
    var textureAtlas: SKTextureAtlas { get set }
    func spawn(parentNode: SKNode, position: CGPoint, size:
        CGSize)
    
    func onTap()
}

class GameScene: SKScene, SKPhysicsContactDelegate, UIAccelerometerDelegate {
    
    let world = SKNode()
    let background = Background()
    let midground = Midground()
    let foreground = Foreground()
    let star = Star()
    let myPlane = MyPlane()
    let bullet = Bullet()
    let bomb = Bomb()
    let enemies = Enemies()
    let enemyFire = EnemyFire()
    let enemyMissiles = EnemyMissiles()
    
    
    // The scroll version of the nodes will become a scrolling, repeating backround
    
    // Main background texture
    var myBackground: SKTexture!
    
    // Calls the sprite a scene object
    var midground1 = SKSpriteNode()
    var midground2 = SKSpriteNode()
    var foreground1 = SKSpriteNode()
    var foreground2 = SKSpriteNode()
    var mtHeight = CGFloat(200)
    
    // Makes sprite an object
    var badCloud  =
        SKSpriteNode(imageNamed: "badCloud.png")
    
    // Enemies
    var enemy1 = SKSpriteNode()
    var enemy2 = SKSpriteNode()
    var enemy3 = SKSpriteNode()
    var tank   = SKSpriteNode()
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
        // Sets the physics delegate and physics body
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsWorld.contactDelegate = self // Physics delegate set
        
        // Calling func for animated background
        background.createBackground()
        
        // Adding a midground
        midground.createMidground()
        
        // Adding the foreground
        foreground.createForeground()
        
        // Add user's bi-plane
        myPlane.animateMyPlane()
        
        // Spawning stars
        star.createStars()
        
        // Initilize values and labels
        initializeValues()
        
        // Set bullet spawn
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(GameScene.SpawnBullets), userInfo: nil, repeats: true)
        
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
            
            myPlane.position.y = location.y // Allows a tap to touch on the y axis
            myPlane.position.x = location.x
            
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
            
            myPlane.position.y = location.y // Allows a tap to touch on the y axis
            myPlane.position.x = location.x
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
        myPlane.physicsBody?.collisionBitMask = groundMask | cloudMask | mtMask | missileMask | enemyMask
        
        // Which ones react to a collision
        
        // Bullet contacts
        bullet.physicsBody?.contactTestBitMask = bullet.physicsBody!.collisionBitMask | starMask | enemy1Mask | enemy2Mask | enemy3Mask | tankMask | missileMask
        
        // MyPlane's contacts
        myPlane.physicsBody?.contactTestBitMask = myPlane.physicsBody!.collisionBitMask | groundMask | mtMask | enemy1Mask | enemy2Mask | enemy3Mask | tankMask | missileMask | enemyMask
    }
    
    
    /********************************* Update Function *********************************/
    // MARK: - Update Function
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        // Animating midground
        midground1.position = CGPointMake(midground1.position.x - 4, 600)
        midground2.position = CGPointMake(midground2.position.x - 4, midground2.position.y)
        
        if (midground1.position.x < -midground1.size.width + 400 / 2){
            midground1.position = CGPointMake(midground2.position.x + midground2.size.width * 4, mtHeight)
        }
        
        if (midground2.position.x < -midground2.size.width + 400 / 2) {
            midground2.position = CGPointMake(midground1.position.x + midground1.size.width * 4, mtHeight)
        }
        
        if (midground1.position.x < self.frame.width/2) {
            mtHeight = randomNumbers(600, secondNum: 240)
        }
        
        // Animating foreground
        foreground1.position = CGPointMake(foreground1.position.x - 6, foreground1.position.y)
        foreground2.position = CGPointMake(foreground2.position.x - 6, foreground2.position.y)
        
        if (foreground1.position.x < -foreground1.size.width / 2) {
            foreground1.position = CGPointMake(foreground2.position.x + foreground2.size.width, foreground1.position.y)
        }
        
        if (foreground2.position.x < -foreground2.size.width / 2) {
            foreground2.position = CGPointMake(foreground1.position.x + foreground1.size.width, foreground2.position.y)
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
//        checkIfGameIsOver()
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
    
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }

    // Spawns an enemy
    func SpawnSkyEnemy() {
        // Calculate random spawn points for air enemies
        let minValue = Int(self.size.height / 8)
        let maxValue = Int(self.size.height - 30)
        let spawnPoint = UInt32(maxValue - minValue)
        
        // Generate a random enemy array
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
        healthLabel.fontSize = 40
        healthLabel.fontColor = SKColor.blackColor()
        healthLabel.position = CGPoint(x: frame.minX + 100, y: frame.minY + 40)
        
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = SKColor.blackColor()
        scoreLabel.position = CGPoint(x: frame.maxX - 100, y: frame.maxY - 40)
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
//    func checkIfGameIsOver(){
//        if (health <= 0 && gameOver == false){
//            self.removeAllChildren()
//            showGameOverScreen()
//            gameOver = true
//        }
//    }
    
    // Checks if an enemy plane reaches the other side of our screen
    func checkIfPlaneGetsAcross(){
        for child in self.children {
            if(child.position.x == 0){
                self.removeChildrenInArray([child])
                currentNumberOfEnemies-=1
                health -= 1
            }
        }
    }
    
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
