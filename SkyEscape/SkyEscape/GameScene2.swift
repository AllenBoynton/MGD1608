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


// Binary connections for collision and colliding
struct PhysicsCategory {
    static let Ground   : UInt32 = 0x1 << 0 // 1
    static let MyBullets: UInt32 = 0x1 << 1 // 2
    static let MyPlane  : UInt32 = 0x1 << 2 // 4
    static let Enemy    : UInt32 = 0x1 << 3 // 8
    static let EnemyFire: UInt32 = 0x1 << 4 // 16
    static let Cloud    : UInt32 = 0x1 << 5 // 32
    static let Star     : UInt32 = 0x1 << 6 // 64
    static let Rain     : UInt32 = 0x1 << 7 // 128
    static let SkyBombs : UInt32 = 0x1 << 8 // 256
}
    
// Global emitter objects
var gunfire   : SKEmitterNode!
var smoke     : SKEmitterNode!
var explode   : SKEmitterNode!
var smokeTrail: SKEmitterNode!
var explosion : SKEmitterNode!
var rain      : SKEmitterNode!

// Global sound
// Audio nodes for sound effects and music
var audioPlayer = AVAudioPlayer()
var bgMusic = SKAudioNode()
var mp5GunSound = SKAudioNode()
var biplaneSound = SKAudioNode()
var gunfireSound = SKAudioNode()
var starSound = SKAudioNode()
var propSound = SKAudioNode()
var flyBySound = SKAudioNode()
var crashSound = SKAudioNode()
var heliSound = SKAudioNode()
var bombDropSound = SKAudioNode()
var battleSound = SKAudioNode()
var skyBoomSound = SKAudioNode()
var bGCannonsSound = SKAudioNode()
var airplaneFlyBySound = SKAudioNode()

// HUD global variables
let maxHealth = 100
let healthBarWidth: CGFloat = 175
let healthBarHeight: CGFloat = 10
let playerHealthBar = SKSpriteNode()

let darkenOpacity: CGFloat = 0.5
let darkenDuration: CFTimeInterval = 2



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var pulseAnimation = SKAction()
    var gameStarted = Bool()
    
    // Location for touch screen
    var touchLocation = CGPointZero
    
    // Main background
    var myBackground = SKSpriteNode()
    
    // Mid background
    var midground1 = SKSpriteNode()
    var midground2 = SKSpriteNode()
    
    // Foreground
    var foreground = SKSpriteNode()
    
    // MyPlane animation setup
    var myPlane = SKSpriteNode()
    var planeArray = [SKTexture]()
    var planeAtlas: SKTextureAtlas =
        SKTextureAtlas(named: "Images.atlas")
    
    // Sky nodes
    var badCloud = SKSpriteNode()
    var paratrooper = SKSpriteNode()
    var powerUpHealth = SKSpriteNode()
    var powerUpArray = [SKTexture]()
    var powerUpAtlas: SKTextureAtlas = SKTextureAtlas(named: "Health.atlas")
        
    // Player's weapons
    var bullets = SKSpriteNode()
    var bombs = SKSpriteNode()
    
    // Wingmen for background show
    var wingman1 = SKSpriteNode(imageNamed: "wingman1")
    var wingman2 = SKSpriteNode(imageNamed: "wingman2")
    var wingman3 = SKSpriteNode(imageNamed: "wingman3")
    var wingman4 = SKSpriteNode(imageNamed: "wingman4")
    var wingmen: [SKSpriteNode] = []
    var myRandom = SKSpriteNode()
    
    // Enemy planes / Ground / weapons
    var enemy1 = SKSpriteNode(imageNamed: "enemy1")
    var enemy2 = SKSpriteNode(imageNamed: "enemy2")
    var enemy3 = SKSpriteNode(imageNamed: "enemy3")
    var enemy4 = SKSpriteNode(imageNamed: "enemy4")
    var enemy5 = SKSpriteNode(imageNamed: "enemy5")
    var enemyArray: [SKSpriteNode] = []
    var randomEnemy = SKSpriteNode()
    var enemyFire = SKSpriteNode()
    
    // Timers for spawn / interval / delays
    var timer = NSTimer()
    var starTimer = NSTimer()
    var wingTimer = NSTimer()
    var paraTimer = NSTimer()
    var enemyTimer = NSTimer()
    var enemyShoots = NSTimer()
    var cloudTimer  = NSTimer()
    var explosions  = NSTimer()
    
    // Game metering GUI
    var score = 0
    var powerUpCount = 0
    var health = 20
    var playerHP = maxHealth
    var gameOver = Bool()
    let maxNumberOfEnemies = 6
    var currentNumberOfEnemies = 0
    var enemySpeed = 5.0
    let moveFactor = 1.0
    var timeBetweenEnemies = 3.0
    var now = NSDate()
    var nextTime = NSDate()
    var dateLabel = SKLabelNode()
    var healthLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var display = SKSpriteNode()
    var pauseNode = SKSpriteNode()
    var pauseButton = SKLabelNode()
    var darkenLayer: SKSpriteNode?
    var gameOverLabel: SKLabelNode?
    var gamePaused = false
    
    
    /********************************** didMoveToView Function **********************************/
    // MARK: - didMoveToView
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        /***************************** Adding Scroll Background *********************************/
        // MARK: - Scroll Background
        
        // Adding scrolling Main Background
        createBackground()
        
        // Adding scrolling midground
        createMidground()
        
        // Adding scrolling foreground
        createForeground()
    }
    
    
    /********************************* touchesBegan Function **************************************/
    // MARK: - touchesBegan
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        if gameStarted == false {
            
            gameStarted = true
            
            
            touchLocation = touches.first!.locationInNode(self)
            
            for touch: AnyObject in touches {
                let location = (touch as! UITouch).locationInNode(self)
                
                // Sets the physics delegate and physics body
                self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
                self.physicsWorld.contactDelegate = self // Physics delegate set
                
                // Allows user to move plane upon begin touch
                myPlane.position.y = location.y // Allows a tap to touch on the y axis
                myPlane.position.x = location.x // Allows a tap to touch on the x axis
                
                // Adding Healthbar to screen
                self.addChild(playerHealthBar)
                updateHealthBar(playerHealthBar, withHealthPoints: playerHP)
                
                // Added HUD with PAUSE
                createHUD()
                
                // Initilize values and labels
                initializeValues()
                
                
                /**************************** Spawning Nodes *************************************/
                // MARK: - Spawning
                
                // Adding our player's plane to the scene
                animateMyPlane()
                
                
                /***************************** Spawn Timers **************************************/
                // MARK: - Spawn Timers
                
                // Spawning bullets timer call
                timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GameScene.spawnBullets), userInfo: nil, repeats: false)
                
                // Spawning wingmen timer call
                wingTimer = NSTimer.scheduledTimerWithTimeInterval(12.0, target: self, selector: #selector(GameScene.spawnWingmen), userInfo: nil, repeats: true)
                
                // Spawning enemies timer call
                enemyTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(GameScene.spawnEnemyPlane), userInfo: nil, repeats: true)
                
                // Spawning enemy fire timer call
                enemyShoots = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GameScene.spawnEnemyFire), userInfo: nil, repeats: true)
                
                explosions = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(GameScene.skyExplosions), userInfo: nil, repeats: true)
                
                // Spawning wingmen timer call
                paraTimer = NSTimer.scheduledTimerWithTimeInterval(13.0, target: self, selector: #selector(GameScene.paratrooperJump), userInfo: nil, repeats: true)
                
                // Cloud sound timer will for 12 sec and stop, then run again
                cloudTimer = NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: #selector(GameScene.rainBadCloud), userInfo: nil, repeats: true)
                
                // Spawning stars timer call
                starTimer = NSTimer.scheduledTimerWithTimeInterval(32.0, target: self, selector: #selector(GameScene.spawnStar), userInfo: nil, repeats: true)
                
                // Put bad cloud on a linear interpolation path
                runAction(SKAction.repeatActionForever(SKAction.sequence([
                    SKAction.runBlock(cloudOnAPath),
                    SKAction.waitForDuration(12.0)
                    ])
                    ))
                

                /*********************** Preloading Sound & Music *********************************/
                // MARK: - Pre-loading AVAudio
                
                // After import AVFoundation, needs do,catch statement to preload sound so no delay
                do {
                    let sounds = ["battle", "bgMusic", "biplaneFlying", "gunfire", "mp5Gun", "heli", "star", "crash", "bombDrop", "prop", "flyBy", "bGCannons", "skyBoom", "airplaneFlyBy"]
                    
                    for sound in sounds {
                        let player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(sound, ofType: "mp3")!))
                        player.prepareToPlay()
                    }
                }
                catch {
                    print("AVAudio has had an \(error).")
                }
                
                // Adds background sound to game
                bgMusic = SKAudioNode(fileNamed: "bgMusic")
                bgMusic.runAction(SKAction.play())
                bgMusic.autoplayLooped = true
                self.addChild(bgMusic)

                biplaneSound = SKAudioNode(fileNamed: "biplaneFlying")
                biplaneSound.runAction(SKAction.play())
                biplaneSound.autoplayLooped = true
                self.addChild(biplaneSound)
                
                
                /*********************** Pausing & Game Over *********************************/
                // MARK: - Pausing & Game Over
                
                // Introduces the pause feature
                let node = self.nodeAtPoint(location)
                if (node.name == "PauseButton") || (node.name == "PauseButtonContainer") {
                    showPauseAlert()
                }
                
                // Counts number of enemies
                if let theName = self.nodeAtPoint(location).name {
                    if theName == "Enemy" {
                        self.removeChildrenInArray([self.nodeAtPoint(location)])
                        currentNumberOfEnemies -= 1
                        score += 1
                    }
                }
                
                if (gameOver == true) { // If goal is hit - game is completed
                    initializeValues()
                }
            }
            
            
        }
        else {
            
            
        }
        
        // Spawning bullets for our player
        bullets.hidden = false
        spawnBullets()
        
        // Add sound to firing
        gunfireSound = SKAudioNode(fileNamed: "gunfire")
        gunfireSound.runAction(SKAction.play())
        gunfireSound.autoplayLooped = false
        
        self.addChild(gunfireSound)
        
        addGunfireToPlane()
    }
    
    
    /******************************** touchesMoved Function **************************************/
    // MARK: - touchesMoved
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
        
        for touch: AnyObject in touches {
            let location = (touch as! UITouch).locationInNode(self)
            
            /* Allows to drag on screen and plane will follow
             that axis and shoot at point when released */
            myPlane.position.y = location.y // Allows a tap to touch on the y axis
            myPlane.position.x = location.x // Allows a tap to touch on the x axis
        }
    }
    
    
    /******************************** touchesEnded Function **************************************/
    // MARK: - touchesEnded
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Each node will collide with the equalled item due to bit mask
        
    }
    
    
    /********************************** Simulating Physics ***************************************/
    // MARK: - Simulate Physics
    
    override func didSimulatePhysics() {
        
    }
    
    
    /*********************************** Update Function *****************************************/
    // MARK: - Update Function
    
    override func update(currentTime: NSTimeInterval) {
        
        // Healthbar GUI
        playerHealthBar.position = CGPoint(x: myPlane.position.x, y: myPlane.position.y - myPlane.size.height / 2 - 15)
        
        // Adding to gameplay health attributes
        healthLabel.text = "Health: \(health)"
        
        // Changes health label red if too low
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
                if(child.position.x == 0){
                    self.removeChildrenInArray([child])
                    currentNumberOfEnemies-=1
                    health -= 1
                }
            }
        }
        
        // Displays the game over screen
        func showGameOverScreen(){
            gameOverLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
            gameOverLabel!.text = "Game Over! Score: \(score)"
            gameOverLabel!.fontColor = SKColor.redColor()
            gameOverLabel!.fontSize = 65
            gameOverLabel!.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame));
            self.addChild(gameOverLabel!)
        }
    }

    
    /************************************ didBeginContact *****************************************/
    // MARK: - didBeginContact
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB

        if ((firstBody.categoryBitMask == PhysicsCategory.MyPlane) && (secondBody.categoryBitMask == PhysicsCategory.Ground)) || ((firstBody.categoryBitMask == PhysicsCategory.Ground) && (secondBody.categoryBitMask == PhysicsCategory.MyPlane)) {
            didMyPlaneHitGround(firstBody.node as! SKSpriteNode, Ground: secondBody.node as! SKSpriteNode)
            print("Plane hit Ground")
        } else if ((firstBody.categoryBitMask == PhysicsCategory.Ground) && (secondBody.categoryBitMask == PhysicsCategory.MyPlane)) {
            didMyPlaneHitGround(secondBody.node as! SKSpriteNode, Ground: firstBody.node as! SKSpriteNode)
            print("Plane hit Ground")
        }
//        else if ((firstBody.name == "MyPlane") && (secondBody.name == "Enemy")) {
//            didMyPlaneHitEnemy(firstBody, Enemy: secondBody)
//            print("Plane hit Enemy")
//        } else if ((firstBody.name == "Enemy") && (secondBody.name == "MyPlane")) {
//            didMyPlaneHitEnemy(secondBody, Enemy: firstBody)
//            print("Plane hit Enemy")
//        }
//        else if ((firstBody.name == "MyPlane") && (secondBody.name == "Star")) {
//            didMyPlaneHitStar(firstBody, Star: secondBody)
//            print("Plane hit Stars")
//        } else if ((firstBody.name == "Star") && (secondBody.name == "MyPlane")) {
//            didMyPlaneHitStar(secondBody, Star: firstBody)
//            print("Plane hit Stars")
//        }
//        else if ((firstBody.name == "MyBullets") && (secondBody.name == "Enemy")) {
//            didBulletsHitEnemy(firstBody, Enemy: secondBody)
//            print("Bullets hit Enemy")
//        } else if ((firstBody.name == "Enemy") && (secondBody.name == "MyBullets")) {
//            didBulletsHitEnemy(secondBody, Enemy: firstBody)
//            print("Bullets hit Enemy")
//        }
//        else if ((firstBody.name == "MyBullets") && (secondBody.name == "Cloud")) {
//            didBulletsHitCloud(firstBody, Cloud: secondBody)
//            print("Bullets hit Cloud")
//        } else if ((firstBody.name == "Cloud") && (secondBody.name == "MyBullets")) {
//            didBulletsHitCloud(secondBody, Cloud: firstBody)
//            print("Bullets hit Cloud")
//        }
//        else if ((firstBody.name == "MyBullets") && (secondBody.name == "Star")) {
//            didBulletsHitStar(firstBody, Star: secondBody)
//            print("Bullets hit Star")
//        } else if ((firstBody.name == "Star") && (secondBody.name == "MyBullets")) {
//            didBulletsHitStar(secondBody, Star: firstBody)
//            print("Bullets hit Star")
//        }
//        else if ((firstBody.name == "EnemyFire") && (secondBody.name == "MyPlane")) {
//            didEnemyFireHitMyPlane(firstBody, MyPlane: secondBody)
//            print("EnemyFire hit Me")
//        } else if ((firstBody.name == "MyPlane") && (secondBody.name == "EnemyFire")) {
//            didEnemyFireHitMyPlane(secondBody, MyPlane: firstBody)
//            print("EnemyFire hit Me")
//        } 
//        else if ((firstBody.name == "Enemy") && (secondBody.name == "Rain")) {
//            didRainHitEnemy(secondBody, Enemy: firstBody)
//            print("Rain hit Enemy")
//        }
//        else if ((firstBody.name == "SkyBombs") && (secondBody.name == "MyPlane")) {
//            didSkyBombHitMyPlane(firstBody, MyPlane: secondBody)
//            print("Sky bombs hit Me")
//        } else if ((firstBody.name == "MyPlane") && (secondBody.name == "SkyBombs")) {
//            didSkyBombHitMyPlane(secondBody, MyPlane: firstBody)
//            print("Sky bombs hit Me")
//        }
//        else if ((firstBody.name == "SkyBombs") && (secondBody.name == "Enemy")) {
//            didSkyBombHitEnemy(firstBody, Enemy: secondBody)
//            print("Sky bombs hit Enemy")
//        } else if ((firstBody.name == "Enemy") && (secondBody.name == "SkyBombs")) {
//            didSkyBombHitEnemy(secondBody, Enemy: firstBody)
//            print("Sky bombs hit Enemy")
//        }
    }
    
    
    /***************************** Collision Functions *********************************/
    // MARK: - Collision Functions
    
    // Function if player hits the ground
    func didMyPlaneHitGround(MyPlane: SKSpriteNode, Ground: SKSpriteNode) {
        /* Enemy (including ground or obstacle) will
         emit explosion, smoke and sound when hit*/
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        smoke = SKEmitterNode(fileNamed: "Smoke")
        
        explosion.position = MyPlane.position
        smoke.position = MyPlane.position
        
        self.addChild(explosion)
        self.addChild(smoke)
        
        MyPlane.removeFromParent()
        gunfire.removeFromParent()
        
        crashSound = SKAudioNode(fileNamed: "crash")
        crashSound.runAction(SKAction.play())
        crashSound.autoplayLooped = false
        
        self.addChild(crashSound)
        
        // GAME OVER
    }
    
    // Function if player hit enemy or enemy hits player
    func didMyPlaneHitEnemy(MyPlane: SKSpriteNode, Enemy: SKSpriteNode) {
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        smoke = SKEmitterNode(fileNamed: "Smoke")
        
        explosion.position = Enemy.position
        smoke.position = Enemy.position
        
        Enemy.removeFromParent()
        MyPlane.removeFromParent()
        self.addChild(explosion)
        self.addChild(smoke)
        
        crashSound = SKAudioNode(fileNamed: "crash")
        crashSound.runAction(SKAction.play())
        crashSound.autoplayLooped = false
        
        self.addChild(crashSound)
        
        health -= 10
        score -= 10
    }
    
    // Function if player hits star
    func didMyPlaneHitStar(MyPlane: SKSpriteNode, Star: SKSpriteNode) {
        // The star will emit a spark and sound when hit
        explode = SKEmitterNode(fileNamed: "Explode")
        explode.position = Star.position
        
        self.addChild(explode)
        
        // Adds star to make sound
        Star.removeFromParent()
        
        // Calling pre-loaded sound to the star hits
        starSound = SKAudioNode(fileNamed: "star")
        starSound.runAction(SKAction.play())
        starSound.autoplayLooped = false
        
        self.addChild(starSound)
        
        // Points per star added to score and health
        score += 1
        health += 1
    }
    
    // Function if player hits enemy with weapon
    func didBulletsHitEnemy (MyBullets: SKSpriteNode, Enemy: SKSpriteNode) {
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        smoke = SKEmitterNode(fileNamed: "Smoke")
        
        explosion.position = Enemy.position
        smoke.position = Enemy.position
        
        Enemy.removeFromParent()
        MyBullets.removeFromParent()
        self.addChild(explosion)
        self.addChild(smoke)
        
        crashSound = SKAudioNode(fileNamed: "crash")
        crashSound.runAction(SKAction.play())
        crashSound.autoplayLooped = false
        
        self.addChild(crashSound)
        
        // Hitting an the enemy adds score and health
        score += 10
        health += 2
    }
    
    // Function if player hits star with bullets
    func didBulletsHitStar(MyBullets: SKSpriteNode, Star: SKSpriteNode) {
        // The star will emit a spark and sound when hit
        explode = SKEmitterNode(fileNamed: "Explode")
        explode.position = Star.position
        
        // Adds star to make sound
        Star.removeFromParent()
        MyBullets.removeFromParent()
        self.addChild(explode)
        
        // Calling pre-loaded sound to the star hits
        starSound = SKAudioNode(fileNamed: "star")
        starSound.runAction(SKAction.play())
        starSound.autoplayLooped = false
        
        self.addChild(starSound)
        
        // Points per star added to score and 1 health
        score += 3
        health += 1
    }
    
    // Function if player hit cloud with weapon
    func didBulletsHitCloud (MyBullets: SKSpriteNode, Cloud: SKSpriteNode) {
        rain = SKEmitterNode(fileNamed: "Rain")
        rain.position = Cloud.position
        rain.position = CGPointMake(badCloud.position.x, badCloud.position.y)
        
        MyBullets.removeFromParent()
        
        // Influenced by plane's movement
        rain.targetNode = self.scene
        badCloud.addChild(rain)
    }
    
    // Function if player hit enemy or enemy hits player
    func didEnemyFireHitMyPlane (EnemyFire: SKSpriteNode, MyPlane: SKSpriteNode) {
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        smoke = SKEmitterNode(fileNamed: "Smoke")
        
        explosion.position = MyPlane.position
        smoke.position = MyPlane.position
        
        EnemyFire.removeFromParent()
        MyPlane.removeFromParent()
        gunfire.removeFromParent()
        self.addChild(explosion)
        self.addChild(smoke)
        
        crashSound = SKAudioNode(fileNamed: "crash")
        crashSound.runAction(SKAction.play())
        crashSound.autoplayLooped = false
        
        self.addChild(crashSound)
        
        health -= 5
    }
    
    // Function if player hit enemy or enemy hits player
    func didEnemyFireHitEnemy (EnemyFire: SKSpriteNode, Enemy: SKSpriteNode) {
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        smoke = SKEmitterNode(fileNamed: "Smoke")
        
        explosion.position = Enemy.position
        smoke.position = Enemy.position
        
        EnemyFire.removeFromParent()
        Enemy.removeFromParent()
        gunfire.removeFromParent()
        self.addChild(explosion)
        self.addChild(smoke)
        
        crashSound = SKAudioNode(fileNamed: "crash")
        crashSound.runAction(SKAction.play())
        crashSound.autoplayLooped = false
        
        self.addChild(crashSound)
        
        // We get points when enemy shoots themselves
        score += 3
    }
    
    // Function if sky bomb hits enemy
    func didSkyBombHitEnemy (SkyBomb: SKSpriteNode, Enemy: SKSpriteNode) {
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        smoke = SKEmitterNode(fileNamed: "Smoke")
        
        explosion.position = Enemy.position
        smoke.position = Enemy.position
        
        self.addChild(explosion)
        self.addChild(smoke)
        
        crashSound = SKAudioNode(fileNamed: "crash")
        crashSound.runAction(SKAction.play())
        crashSound.autoplayLooped = false
        
        self.addChild(crashSound)
    }
    
    // Function if sky bomb hits enemy
    func didSkyBombHitMyPlane (SkyBomb: SKSpriteNode, MyPlane: SKSpriteNode) {
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        smoke = SKEmitterNode(fileNamed: "Smoke")
        
        explosion.position = MyPlane.position
        smoke.position = MyPlane.position
        
        self.addChild(explosion)
        self.addChild(smoke)
        
        crashSound = SKAudioNode(fileNamed: "crash")
        crashSound.runAction(SKAction.play())
        crashSound.autoplayLooped = false
        
        self.addChild(crashSound)
        
        // Skybomb takes away health
        health -= 5
        
        playerHP = max(0, health - 20)
    }

    
    /********************************* Background Functions *********************************/
    // MARK: - Background Functions
    
    // Adding scrolling background
    func createBackground() {
        let myBackground = SKTexture(imageNamed: "cartoonCloudsBGLS")
        
        for i in 0...1 {
            let background = SKSpriteNode(texture: myBackground)
            background.zPosition = 0
            background.anchorPoint = CGPointZero
            background.position = CGPoint(x: (myBackground.size().width * CGFloat(i)) - CGFloat(1 * i), y: 0)
            
            self.addChild(background)
            
            let moveLeft = SKAction.moveByX(-myBackground.size().width, y: 0, duration: 50)
            let moveReset = SKAction.moveByX(myBackground.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatActionForever(moveLoop)
            
            background.runAction(moveForever)
        }
    }

    // Adding scrolling midground
    func createMidground() {
        let midground1 = SKTexture(imageNamed: "mountains")
        
        for i in 0...1 {
            let ground = SKSpriteNode(texture: midground1)
            ground.zPosition = 1
            ground.position = CGPoint(x: (midground1.size().width / 2.0 + (midground1.size().width * CGFloat(i))), y: midground1.size().height / 2)
            
            // Create physics body
            ground.physicsBody?.affectedByGravity = false
            
            self.addChild(ground)
            
            let moveLeft = SKAction.moveByX(-midground1.size().width, y: 0, duration: 30)
            let moveReset = SKAction.moveByX(midground1.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatActionForever(moveLoop)
            
            ground.shadowCastBitMask = 0
            
            ground.runAction(moveForever)
        }
    }
    
    // Adding scrolling foreground
    func createForeground() {
        let foreground = SKTexture(imageNamed: "lonelytree")
        
        for i in 0...1 {
            let ground = SKSpriteNode(texture: foreground)
            ground.zPosition = 10
            ground.position = CGPoint(x: (foreground.size().width / 2.0 + (foreground.size().width * CGFloat(i))), y: foreground.size().height / 2)
            
            // Create physics body
            ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
//            ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
            ground.physicsBody?.collisionBitMask = PhysicsCategory.MyPlane
            ground.physicsBody?.contactTestBitMask = ground.physicsBody!.collisionBitMask | PhysicsCategory.MyPlane
            ground.name = "Ground"
            ground.physicsBody?.dynamic = false
            ground.physicsBody?.affectedByGravity = false
            
            self.addChild(ground)
            
            let moveLeft = SKAction.moveByX(-foreground.size().width, y: 0, duration: 5)
            let moveReset = SKAction.moveByX(foreground.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatActionForever(moveLoop)
            
            ground.runAction(moveForever)
        }
    }
    
    
    /*********************************** Animation Functions *********************************/
    // MARK: - Plane animation functions
    
    func animateMyPlane() {
        
        for i in 1...planeAtlas.textureNames.count { // Iterates loop for plane animation
            let plane = "myPlane\(i).png"
            planeArray.append(SKTexture(imageNamed: plane))
        }
        
        // Add user's animated bi-plane
        myPlane = SKSpriteNode(imageNamed: planeAtlas.textureNames[0])
        myPlane.setScale(0.2)
        myPlane.zPosition = 11
        myPlane.position = CGPoint(x: self.size.width / 6, y: self.size.height / 2)
        
        // Body physics of player's plane
        myPlane.physicsBody = SKPhysicsBody(rectangleOfSize: myPlane.size)
//        myPlane.physicsBody?.categoryBitMask = PhysicsCategory.MyPlane
        myPlane.physicsBody?.collisionBitMask = PhysicsCategory.Enemy | PhysicsCategory.Ground | PhysicsCategory.EnemyFire | PhysicsCategory.SkyBombs
        myPlane.physicsBody?.contactTestBitMask = myPlane.physicsBody!.collisionBitMask | PhysicsCategory.Ground | PhysicsCategory.Enemy | PhysicsCategory.EnemyFire | PhysicsCategory.SkyBombs | PhysicsCategory.Star
        myPlane.name = "MyPlane"
        myPlane.physicsBody?.dynamic = false
        myPlane.physicsBody?.affectedByGravity = false
        
        myPlane.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(planeArray, timePerFrame: 0.05)))
        
        self.addChild(myPlane)        
    }
    
    
    /*********************************** Spawning Functions *********************************/
    // MARK: - Spawning Functions
    
    // Spawn bullets for player's plane
    func spawnBullets() {
        
        // Setup bullet node
        bullets = SKSpriteNode(imageNamed: "silverBullet")
        bullets.zPosition = 11
        
        bullets.position = CGPoint(x: myPlane.position.x + 50, y: myPlane.position.y)
        
        // Body physics of player's bullets
        bullets.physicsBody = SKPhysicsBody(rectangleOfSize: bullets.size)
        bullets.physicsBody?.categoryBitMask = PhysicsCategory.MyBullets
        bullets.physicsBody?.collisionBitMask = PhysicsCategory.Enemy | PhysicsCategory.EnemyFire | PhysicsCategory.Cloud | PhysicsCategory.Star
        bullets.physicsBody?.contactTestBitMask = bullets.physicsBody!.collisionBitMask | PhysicsCategory.Enemy | PhysicsCategory.EnemyFire | PhysicsCategory.SkyBombs
        bullets.name = "MyBullets"
        bullets.physicsBody?.usesPreciseCollisionDetection = true
        bullets.physicsBody?.dynamic = false
        bullets.physicsBody?.affectedByGravity = false
        
        // Collision shows they only met
        //            ball.physicsBody?.collisionBitMask = wallMask | ballMask | pegMask | orangePegMask
        // Which ones have a REACTION to a collision
        //            ball.physicsBody?.contactTestBitMask = ball.physicsBody!.collisionBitMask | squareMask | bucketMask
        

        
        // Shoot em up!
        let action = SKAction.moveToX(self.size.width + 100, duration: 0.7)
        let actionDone = SKAction.removeFromParent()
        bullets.runAction(SKAction.sequence([action, actionDone]))
        
        self.addChild(bullets)
    }
    
    // Adding ally forces in background
    func spawnWingmen() {
        
        // Alternate wingmen passby's in the distance
        wingmen = [wingman1, wingman2, wingman3, wingman4]
        
        // Generate a random index
        let randomIndex = Int(arc4random_uniform(UInt32(wingmen.count)))
        
        // Get a random enemy
        myRandom = wingmen[randomIndex]
        
        myRandom.zPosition = 4
        myRandom.setScale(0.3)
        
        // Calculate random spawn points for bomber
        let random = CGFloat(arc4random_uniform(1000) + 400)
        myRandom.position = CGPoint(x: -self.size.width, y: random)
        
        // Body physics for player's bomber
        myRandom.physicsBody = SKPhysicsBody(rectangleOfSize: myRandom.size)
        myRandom.physicsBody?.affectedByGravity = false
        myRandom.physicsBody?.dynamic = false
        
        // Move bomber forward
        let action = SKAction.moveToX(self.size.width + 100, duration: 12.0)
        let actionDone = SKAction.removeFromParent()
        myRandom.runAction(SKAction.sequence([action, actionDone]))
        
        myRandom.removeFromParent()
        self.addChild(myRandom) // Generate the random wingman
        
        propSound = SKAudioNode(fileNamed: "prop")
        propSound.runAction(SKAction.play())
        propSound.autoplayLooped = false
        self.addChild(propSound)
    }
    
    // Generate enemy fighter planes
    func spawnEnemyPlane() {
        
        // Sky enemy array
        enemyArray = [enemy1, enemy2, enemy3, enemy4, enemy5]
        
        // Generate a random index
        let randomIndex = Int(arc4random_uniform(UInt32(enemyArray.count)))
        
        // Get a random enemy
        randomEnemy = enemyArray[randomIndex]

        randomEnemy.setScale(0.7)
        randomEnemy.zPosition = 9
        
        // Calculate random spawn points for air enemies
        randomEnemy.position = CGPoint(x: self.size.width, y: CGFloat(arc4random_uniform(700) + 250))
        
        // Body physics for enemy's planes
        randomEnemy.physicsBody = SKPhysicsBody(rectangleOfSize: randomEnemy.size)
        randomEnemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        randomEnemy.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane | PhysicsCategory.MyBullets | PhysicsCategory.Enemy | PhysicsCategory.EnemyFire | PhysicsCategory.SkyBombs
        randomEnemy.physicsBody?.collisionBitMask = PhysicsCategory.MyPlane | PhysicsCategory.MyBullets | PhysicsCategory.Enemy | PhysicsCategory.EnemyFire | PhysicsCategory.SkyBombs | PhysicsCategory.Cloud
        randomEnemy.name = "Enemy"
        randomEnemy.physicsBody?.dynamic = false
        randomEnemy.physicsBody?.affectedByGravity = false

        // Move enemies forward
        let action = SKAction.moveToX(-200, duration: 4.0)
        let actionDone = SKAction.removeFromParent()
        randomEnemy.runAction(SKAction.sequence([action, actionDone]))
        
        randomEnemy.removeFromParent()
        self.addChild(randomEnemy) // Generate the random enemy
        
        // Add plane sound
        flyBySound = SKAudioNode(fileNamed: "flyBy")
        flyBySound.runAction(SKAction.play())
        flyBySound.autoplayLooped = false
        self.addChild(flyBySound)
        
        // Add gun sound
        mp5GunSound = SKAudioNode(fileNamed: "mp5Gun")
        mp5GunSound.runAction(SKAction.play())
        mp5GunSound.autoplayLooped = false
        self.addChild(mp5GunSound)
        
        spawnEnemyFire()
    }

    func spawnEnemyFire() {
        enemyFire = SKSpriteNode(imageNamed: "enemyFire")
        enemyFire.setScale(1.0)
        enemyFire.zPosition = 9

        enemyFire.position = CGPointMake(randomEnemy.position.x - 75, randomEnemy.position.y)

        // Body physics of player's bullets
        enemyFire.physicsBody = SKPhysicsBody(rectangleOfSize: enemyFire.size)
        enemyFire.physicsBody?.categoryBitMask = PhysicsCategory.EnemyFire
        enemyFire.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane | PhysicsCategory.Enemy | PhysicsCategory.MyBullets
        enemyFire.physicsBody?.collisionBitMask = PhysicsCategory.MyPlane | PhysicsCategory.Enemy | PhysicsCategory.MyBullets | PhysicsCategory.Cloud | PhysicsCategory.Star
        enemyFire.name = "EnemyFire"
        enemyFire.physicsBody?.dynamic = false
        enemyFire.physicsBody?.affectedByGravity = false
        
        // Change attributes
        enemyFire.color = UIColor.yellowColor()
        enemyFire.colorBlendFactor = 1.0

        // Shoot em up!
        let action = SKAction.moveToX(-30, duration: 1.0)
        let actionDone = SKAction.removeFromParent()
        enemyFire.runAction(SKAction.sequence([action, actionDone]))
        
        self.addChild(enemyFire) // Generate enemy fire
    }
    
    func skyExplosions() {
        
        // Sky explosions of a normal battle
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        explosion.particleLifetime = 0.5
        explosion.particleScale = 0.4
        explosion.particleSpeed = 1.5
        explosion.zPosition = 9
        
        // Physics for sky bomb
        explosion.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        explosion.physicsBody?.categoryBitMask = PhysicsCategory.SkyBombs
        explosion.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane | PhysicsCategory.Enemy
        explosion.physicsBody?.collisionBitMask = PhysicsCategory.MyPlane | PhysicsCategory.Enemy
        explosion.name = "SkyBomb"
        explosion.physicsBody?.dynamic = false
        explosion.physicsBody?.affectedByGravity = false
        
        // Randomly place stars on Y axis
        let actualY = arc4random_uniform(UInt32(frame.size.height) - 300)
        let actualX = arc4random_uniform(UInt32(frame.size.width))
        explosion.position.x = CGFloat(actualX)
        explosion.position.y = CGFloat(actualY)
        
        self.addChild(explosion)
        
        skyBoomSound = SKAudioNode(fileNamed: "skyBoom")
        skyBoomSound.runAction(SKAction.play())
        skyBoomSound.autoplayLooped = false
        self.addChild(skyBoomSound)
    }
    
    func paratrooperJump() {
        
        // Jumping for their lives!
        paratrooper = SKSpriteNode(imageNamed: "paratrooper")
        paratrooper.setScale(0.75)
        paratrooper.zPosition = 7
        
        let actualX = CGFloat.random(min: paratrooper.size.width, max: size.height - paratrooper.size.width / 2 - 200)
        paratrooper.position = CGPoint(x: actualX, y: size.height + paratrooper.size.height)
        
        // Physics for paratrooper
        paratrooper.physicsBody?.affectedByGravity = false
        paratrooper.physicsBody?.dynamic = true
        
        // Move enemies forward
        let action = SKAction.moveToY(-70, duration: 15.0)
        let actionDone = SKAction.removeFromParent()
        paratrooper.runAction(SKAction.sequence([action, actionDone]))
        
        self.addChild(paratrooper)
    }
    
    // Spawning a bonus star
    func spawnStar() {
        
        // Randomly place stars on Y axis
//        let actualY = CGFloat.random(min: 400, max: self.frame.size.height - 100)
//        let actualX = CGFloat.random(min: star.size.width / 2, max: size.width - star.size.width / 3 - 50)
//        
//        // Star position off screen
//        star.position = CGPoint(x: actualX, y: actualY)
//        star.setScale(3.0)
//        star.zPosition = 11
//        
//        // Added star's physics
//        star.physicsBody = SKPhysicsBody(edgeLoopFromRect: star.frame)
//        star.physicsBody?.categoryBitMask = PhysicsCategory.Star
//        star.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane | PhysicsCategory.MyBullets | PhysicsCategory.Enemy | PhysicsCategory.EnemyFire
//        star.physicsBody?.collisionBitMask = PhysicsCategory.MyBullets | PhysicsCategory.EnemyFire
//        star.physicsBody?.dynamic = false
//        star.physicsBody?.affectedByGravity = false
//        
//        // Since the star texture is only one frame, we can set it here:
//        star = SKSpriteNode(imageNamed: "star")
//        star.runAction(pulseAnimation)
//        
//        starSound = SKAudioNode(fileNamed: "star")
//        starSound.runAction(SKAction.play())
//        starSound.autoplayLooped = false
//        self.addChild(starSound)
//        
//        self.addChild(star)
//        
        createAnimations()
    }
    
    // Animation for star
    func createAnimations() {
        
        // Scale the star smaller and fade it slightly:
        let pulseOutGroup = SKAction.group([
            SKAction.fadeAlphaTo(0.85, duration: 0.8),
            SKAction.scaleTo(0.6, duration: 0.8),
            SKAction.rotateByAngle(-0.3, duration: 0.8)
            ])
        
        // Push the star big again, and fade it back in:
        let pulseInGroup = SKAction.group([
            SKAction.fadeAlphaTo(1, duration: 1.5),
            SKAction.scaleTo(1, duration: 1.5),
            SKAction.rotateByAngle(3.5, duration: 1.5)
            ])
        
        // Combine the two into a sequence:
        let pulseSequence = SKAction.sequence([pulseOutGroup, pulseInGroup])
        pulseAnimation = SKAction.repeatActionForever(pulseSequence)
    }
    
    // Introducing the cloud using linear interpolation
    func cloudOnAPath() {
        
        badCloud = SKSpriteNode(imageNamed: "badCloud")
        badCloud.zPosition = 4
        
        // Randomly place cloud on Y axis
        let actualY = CGFloat.random(min: 400, max: self.frame.size.height - 100)
        
        // Clouds position off screen
        badCloud.position = CGPoint(x: size.width + badCloud.size.width / 2, y: actualY)
        
        // This time I will determine speed by velocity rather than time interval
        let actualDuration = CGFloat.random(min: CGFloat(10.0), max: CGFloat(15.0))
        
        // Added cloud's physics
        badCloud.physicsBody = SKPhysicsBody(edgeLoopFromRect: badCloud.frame)
        badCloud.physicsBody?.categoryBitMask = PhysicsCategory.Cloud 
        badCloud.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane | PhysicsCategory.MyBullets
        badCloud.physicsBody?.collisionBitMask = PhysicsCategory.MyBullets | PhysicsCategory.MyPlane
        badCloud.name = "Cloud"
        badCloud.physicsBody?.dynamic = false
        badCloud.physicsBody?.affectedByGravity = false
        
        self.addChild(badCloud) // Generate "bonus" star
        
        // Create a path func cloudOnAPath() {
        let actionMove = SKAction.moveTo(CGPoint(x: -badCloud.size.width / 2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        badCloud.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        badCloud.shadowCastBitMask = 0
        badCloud.lightingBitMask = 0
    }
    

    /*********************************** Emitter Functions *********************************/
    // MARK: - Emitter Functions
    
    // Adding emitter to follow cloud and rain in time intervals
    func rainBadCloud() {
        
        // Cloud will rain within intervals
        rain = SKEmitterNode(fileNamed: "Rain")
        rain.zPosition = 3
        rain.setScale(0.8)
        
        // Set physics for rain
        rain.physicsBody = SKPhysicsBody(rectangleOfSize: rain.particleSize)
        rain.physicsBody?.categoryBitMask = PhysicsCategory.Rain
        rain.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane | PhysicsCategory.Enemy
        rain.physicsBody?.collisionBitMask = PhysicsCategory.MyPlane | PhysicsCategory.Enemy
        rain.name = "Rain"
        rain.physicsBody?.dynamic = true
        rain.physicsBody?.affectedByGravity = false
        
        // Follows cloud
        rain.targetNode = self.scene
//        badCloud.addChild(rain)
    }
    
    // Add emitter of fire when bullets are fired
    func addGunfireToPlane() {
        
        // The plane will emit gunfire effect
        gunfire = SKEmitterNode(fileNamed: "Gunfire")
        gunfire.zPosition = 9
        gunfire.particleScale = 0.6
        
        // Stays with plane
        gunfire.targetNode = self.scene
        myPlane.addChild(gunfire)
    }
    
    // Add emitter of exhaust smoke behind plane
    func addSmokeTrail() {
        
        // Create smoke trail for myPlane
        smokeTrail = SKEmitterNode(fileNamed: "SmokeTrail")
        smokeTrail.particleScale = 1.2
        
        // Influenced by plane's movement
        smokeTrail.targetNode = self.scene
//        myPlane.addChild(smokeTrail)
    }
    
    
    /*************************************** Pause ******************************************/
    // MARK: - Pause Functionality
    
    // Show Pause Alert
    func showPauseAlert() {
        self.gamePaused = true
        let alert = UIAlertController(title: "Pause", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default)  { _ in
            self.gamePaused = false
            })
        self.view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func createHUD() {
        
        // Adding HUD with pause
        display = SKSpriteNode(color: UIColor.blackColor(), size: CGSizeMake(self.size.width, self.size.height * 0.05))
        display.anchorPoint = CGPointMake(0, 0)
        display.position = CGPointMake(0, self.size.height - display.size.height)
        display.zPosition = 15
        
        // Pause button container
        pauseNode.position = CGPoint(x: display.size.width / 2, y: display.size.height / 2)
        pauseNode.size = CGSizeMake(display.size.height * 3, display.size.height * 2.5)
        pauseNode.name = "PauseButtonContainer"
        
        // Pause label
        pauseButton = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        pauseButton.position = CGPoint(x: display.size.width / 2, y: display.size.height / 2 - 25)
        pauseButton.text = "PAUSE"
        pauseButton.fontSize = display.size.height
        pauseButton.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        pauseButton.name = "PauseButton"
        pauseButton.horizontalAlignmentMode = .Center
        
        // Health label
        healthLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        health = 20
        healthLabel.text = "Health: \(health)"
        healthLabel.fontSize = display.size.height
        healthLabel.fontColor = SKColor.whiteColor()
        healthLabel.position = CGPoint(x: 175, y: display.size.height / 2 - 25)
        scoreLabel.horizontalAlignmentMode = .Left
        healthLabel.zPosition = 15
        
        // Score label
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        score = 0
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = display.size.height
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.position = CGPoint(x: display.size.width - 40, y: display.size.height / 2 - 25)
        scoreLabel.horizontalAlignmentMode = .Right
        scoreLabel.zPosition = 15
        
        self.addChild(display)
        display.addChild(pauseNode)
        display.addChild(pauseButton)
        display.addChild(healthLabel)
        display.addChild(scoreLabel)
    }
    
    func holdGame() {
        
        self.gamePaused = true
        
        // Stop movement, fade out, move to center, fade in
        self.removeAllActions()
        self.myPlane.runAction(SKAction.fadeOutWithDuration(1) , completion: {
            self.myPlane.position = CGPointMake(self.size.width / 2, self.size.height / 2)
            self.myPlane.runAction(SKAction.fadeInWithDuration(1), completion: {
                self.gamePaused = false
            })
        })
    }
    
 
    /******************************* Healthbar GUI Function *********************************/
    // MARK: - Healthbar GUI Function
    
    // Healthbar function for visual display
    func updateHealthBar(node: SKSpriteNode, withHealthPoints hp: Int) {
        
        let barSize = CGSize(width: healthBarWidth, height: healthBarHeight)
        
        let fillColor = UIColor(red: 113.0/255, green: 202.0/255, blue: 53.0/255, alpha:1)
        let borderColor = UIColor(red: 35.0/255, green: 28.0/255, blue: 40.0/255, alpha:1)
        
        // create drawing context
        UIGraphicsBeginImageContextWithOptions(barSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // draw the outline for the health bar
        borderColor.setStroke()
        let borderRect = CGRect(origin: CGPointZero, size: barSize)
        CGContextStrokeRectWithWidth(context, borderRect, 1)
        
        // draw the health bar with a colored rectangle
        fillColor.setFill()
        let barWidth = (barSize.width - 1) * CGFloat(hp) / CGFloat(maxHealth)
        let barRect = CGRect(x: 0.5, y: 0.5, width: barWidth, height: barSize.height - 1)
        CGContextFillRect(context, barRect)
        
        // extract image
        let spriteImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // set sprite texture and size
        node.texture = SKTexture(image: spriteImage)
        node.size = barSize
        
        playerHealthBar.position = CGPoint(
            x: myPlane.position.x,
            y: myPlane.position.y - myPlane.size.height / 2 - 15
        )
        
        playerHealthBar.zPosition = 11
    }

    
    //Sets the initial values for our variables
    func initializeValues(){
//        self.removeAllChildren()
        
        gameOver = false
        currentNumberOfEnemies = 0
        timeBetweenEnemies = 1.0
        nextTime = NSDate()
        now = NSDate()
        
        gameOverLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        gameOverLabel!.text = "GAME OVER"
        gameOverLabel!.fontSize = 80
        gameOverLabel!.fontColor = SKColor.blackColor()
        gameOverLabel!.position = CGPoint(x: CGRectGetMinX(self.frame)/2, y: (CGRectGetMinY(self.frame)/2))
        
//        self.addChild(gameOverLabel!)
    }
}
