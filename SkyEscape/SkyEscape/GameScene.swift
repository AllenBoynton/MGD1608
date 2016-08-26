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


// Binary connections for collision and colliding
struct PhysicsCategory {
    static let None     : UInt32 = 0        // 0
    static let Ground   : UInt32 = 0x1 << 0 // 1
    static let MyBullets: UInt32 = 0x1 << 1 // 2
    static let MyPlane  : UInt32 = 0x1 << 2 // 4
    static let Enemy    : UInt32 = 0x1 << 3 // 8
    static let EnemyFire: UInt32 = 0x1 << 4 // 16
    static let Cloud    : UInt32 = 0x1 << 5 // 32
    static let PowerUp  : UInt32 = 0x1 << 6 // 64
    static let Coins    : UInt32 = 0x1 << 7 // 128
    static let SkyBombs : UInt32 = 0x1 << 8 // 256
    static let All      : UInt32 = UInt32.max // all nodes
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
var mortarSound = SKAudioNode()
var powerUpSound = SKAudioNode()
var propSound = SKAudioNode()
var flyBySound = SKAudioNode()
var crashSound = SKAudioNode()
var tankSound = SKAudioNode()
var startGameSound = SKAudioNode()
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
    
    
    // Location for touch screen
    var touchLocation = CGPointZero
    let motionManager = CMMotionManager()
    
    // Game starters
    var gameStarted = Bool()
    var tapPlay: SKTexture?
    let startBTN = SKSpriteNode()
    
    // myPlane animationsetup
    var node = SKNode()
    var myPlane: SKSpriteNode!
    
    // Player's weapons
    var bullets = SKSpriteNode()
    var bombs = SKSpriteNode()
    
    // ally plane animation setup
    var myAlly = SKSpriteNode()
    var myAlly2 = SKSpriteNode()
    
    // Enemy planes
    var skyEnemy = SKSpriteNode()
    
    // Enemy Ground / weapons
    var tank = SKSpriteNode()
    var turret = SKSpriteNode()
    var soldier = SKSpriteNode()
    
    // Sky nodes
    var badCloud = SKSpriteNode()
    var paratrooper = SKSpriteNode()
    var powerUpHealth = SKSpriteNode()
    var skyCoins = SKSpriteNode()
    
    // Image atlas's for animation
    var animation = SKAction()
    var pulseAnimation = SKAction()
    var animationFrames = [SKTexture]()
    var airplanesAtlas: SKTextureAtlas = SKTextureAtlas(named: "Airplanes")
    var allyAtlas: SKTextureAtlas = SKTextureAtlas(named: "AllyPlanes")
    var ally2Atlas: SKTextureAtlas = SKTextureAtlas(named: "AllyPlanes2")
    var assetsAtlas: SKTextureAtlas = SKTextureAtlas(named: "Assets")
    var enemyPlanesAtlas: SKTextureAtlas = SKTextureAtlas(named:"EnemyPlanes")
    var enemyPlanes2Atlas: SKTextureAtlas = SKTextureAtlas(named:"EnemyPlanes2")
    var turretAtlas: SKTextureAtlas = SKTextureAtlas(named: "Turret")
    var soldierShootAtlas: SKTextureAtlas = SKTextureAtlas(named: "SoldierShoot")
    var soldierWalkAtlas: SKTextureAtlas = SKTextureAtlas(named: "SoldierWalk")
    var tankAttackAtlas: SKTextureAtlas = SKTextureAtlas(named:"TankAttack")
    var tankForwardAtlas: SKTextureAtlas = SKTextureAtlas(named:"TankForward")
    
    // Timers for spawn / interval / delays
    var timer = NSTimer()
    var wingTimer = NSTimer()
    var paraTimer = NSTimer()
    var coinsTimer = NSTimer()
    var enemyTimer = NSTimer()
    var enemyShoots = NSTimer()
    var cloudTimer  = NSTimer()
    var explosions  = NSTimer()
    var powerUpTimer = NSTimer()
    
    // Game metering GUI
    var score = 0
    var powerUpCount = 0
    var coinCount = 0
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
    var healthLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var powerUp = SKSpriteNode()
    var powerUpLabel = SKLabelNode()
    var coinImage = SKSpriteNode()
    var coinCountLbl = SKLabelNode()
    var display = SKSpriteNode()
    var pauseNode = SKSpriteNode()
    var pauseButton = SKSpriteNode()
    var darkenLayer: SKSpriteNode?
    var gameOverLabel: SKLabelNode?
    var gamePaused = Bool()
    
    
    /********************************** didMoveToView Function **********************************/
    // MARK: - didMoveToView
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // Sets the physics delegate and physics body
        self.physicsWorld.gravity = CGVectorMake(0, -9.8)

        physicsWorld.contactDelegate = self // Physics delegate set
        
        // Backgroung color set with RGB
        backgroundColor = SKColor.init(red: 127/255, green: 189/255, blue: 248/255, alpha: 1.0)
        
        // Default to texture:
        func tapToPlay(play: UIButton!) {
            tapPlay = assetsAtlas.textureNamed("start")
            
            let startBTN = SKSpriteNode(texture: tapPlay)
            startBTN.zPosition = 20
            startBTN.size = CGSize(width: 300, height: 75)
            startBTN.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
            
            startBTN.removeFromParent()
            self.addChild(startBTN)
            
            startGameSound = SKAudioNode(fileNamed: "startGame")
            startGameSound.runAction(SKAction.play())
            startGameSound.autoplayLooped = false
            self.addChild(startGameSound)
        }
        
        // Updating myPlane per movements with CoreMotion
        var xAcceleration:CGFloat = 0.0
        node = createPlane()
        
        if let myPlane = node.childNodeWithName("myPlane") as? SKSpriteNode {
            
            motionManager.accelerometerUpdateInterval = 0.2
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!) {
                [weak self] accelerometerData, error in
                
                let acceleration = accelerometerData!.acceleration
                xAcceleration = (CGFloat(acceleration.x) * 0.75) + (xAcceleration * 0.25)
                self!.node.position = CGPoint(x: self!.size.width / 2, y: 80.0)
                let texture: SKTexture!
                
                self!.airplanesAtlas = SKTextureAtlas(named: "Airplanes")
                
                switch (xAcceleration) {
                    
                case let x where x > 0.3:
                    texture = SKTexture(imageNamed: "1Fokker_up")
                case let x where x < -0.3:
                    texture = SKTexture(imageNamed: "1Fokker_down")
                default:
                    texture = SKTexture(imageNamed: "1Fokker_default")
                }
                myPlane.texture = texture
            }
        }
        
        // Template loop for animation
        // Loop to run up movement
//        for i in 1...self.planeAtlas.textureNames.count {
//            let plane = "MyFokker\(i)"
//            self.flyFrames.append(SKTexture(imageNamed: plane))
//        }
//        texture = SKTexture(imageNamed: self!.planeAtlas.textureNames[0])
        
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
            
//            // Once game scene is open, all is delayed by 3 seconds
//            let spawn = SKAction.runBlock({ 
//                () in
//                
//                self.createPlane()
//                self.moveBackground()
//                self.moveMidground()
//                self.moveForeground()
//                self.spawnBullets()
//                self.spawnEnemyPlane()
//                self.spawnWingmen()
//                self.paratrooperJump()
//                self.spawnEnemyFire()
//                self.skyExplosions()
////                self.spawnSoldiers()
////                self.spawnTurrets()
////                self.spawnTanks()
////                self.spawnCoins()
//                self.spawnPowerUps()
//                self.createHUD()
//                
//            })
//            
//            let delay = SKAction.waitForDuration(3.0)
//            let spawnDelay = SKAction.sequence([spawn, delay])
//            let spawnDelayForever = SKAction.repeatActionForever(spawnDelay)
//            self.runAction(spawnDelayForever)
//            
            
//            touchLocation = touches.first!.locationInNode(self)
            
            for touch: AnyObject in touches {
                let location = (touch as! UITouch).locationInNode(self)
                
                // Allows user to move plane upon begin touch
                myPlane.position.y = location.y // Allows a tap to touch on the y axis
                myPlane.position.x = location.x // Allows a tap to touch on the x axis
    
                
                /*********************** Pausing & Game Over *********************************/
                // MARK: - Pausing & Game Over
                
                // Introduces the pause feature
                
                createHUD() /* function opens up the HUD and makes the button accessible
                               also, has displays for health and score. */
                
                // Introduces the pause feature
                let node = self.nodeAtPoint(location)
                if (node.name == "PauseButton") || (node.name == "PauseButtonContainer") {
                    showPauseAlert()
                }
            
                
                /**************************** Spawning Nodes *************************************/
                // MARK: - Spawning
                
                // Adding our player's plane to the scene
                createPlane()
                
                // Spawning bullets for our player
                bullets.hidden = false
                spawnBullets()
                
                // Add sound to firing
                gunfireSound = SKAudioNode(fileNamed: "gunfire")
                gunfireSound.runAction(SKAction.play())
                gunfireSound.autoplayLooped = false
                
                self.addChild(gunfireSound)
                
                // Adding Healthbar to screen
                self.addChild(playerHealthBar)
                updateHealthBar(playerHealthBar, withHealthPoints: playerHP)
                
                // Initilize values and labels
                initializeValues()
                
                
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
                
                // Spawning Power Ups timer call
                powerUpTimer = NSTimer.scheduledTimerWithTimeInterval(32.0, target: self, selector: #selector(GameScene.spawnPowerUps), userInfo: nil, repeats: true)
                
                // Spawning Coins timer call
//                let coinsTimer = NSTimer.scheduledTimerWithTimeInterval(32.0, target: self, selector: #selector(GameScene.spawnCoins), userInfo: nil, repeats: true)
                
                // Spawning turrets timer call
//                let turretTimer = NSTimer.scheduledTimerWithTimeInterval(32.0, target: self, selector: #selector(GameScene.spawnTurrets), userInfo: nil, repeats: true)
                
                // Spawning soldiers walk timer call
//                let soldiersWalkTimer = NSTimer.scheduledTimerWithTimeInterval(32.0, target: self, selector: #selector(GameScene.spawnSoldierWalk), userInfo: nil, repeats: true)
                
                // Spawning soldiers shoot timer call
//                let soldiersShootTimer = NSTimer.scheduledTimerWithTimeInterval(32.0, target: self, selector: #selector(GameScene.spawnSoldiersShoot), userInfo: nil, repeats: true)
                
                // Spawning tank drive timer call
//                let tankDriveTimer = NSTimer.scheduledTimerWithTimeInterval(32.0, target: self, selector: #selector(GameScene.spawnTankDrive), userInfo: nil, repeats: true)
                
                // Spawning tank shoot timer call
//                let tankShootTimer = NSTimer.scheduledTimerWithTimeInterval(32.0, target: self, selector: #selector(GameScene.spawnTankShoot), userInfo: nil, repeats: true)
                
                // Put bad cloud on a linear interpolation path
//                runAction(SKAction.repeatActionForever(SKAction.sequence([
//                    SKAction.runBlock(cloudOnAPath),
//                    SKAction.waitForDuration(12.0)
//                    ])
//                    ))
                
                
                /*********************** Preloading Sound & Music *********************************/
                // MARK: - Pre-loading AVAudio
                
                // After import AVFoundation, needs do,catch statement to preload sound so no delay
                do {
                    let sounds = ["battle", "bgMusic", "biplaneFlying", "gunfire", "mp5Gun", "crash", "bombDrop", "prop", "flyBy", "bGCannons", "skyBoom", "airplaneFlyBy", "startGame", "tank", "mortarRound", "powerUp"]
                    
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
        
        if !self.gamePaused {
//            holdGame()
        }
        
        //Puts backgrounds in motion
        moveBackground()
        moveMidground()
        moveForeground()
        
        // Updates position of plane for health bar
//        playerHealthBar.position = CGPoint(x: myPlane.position.x, y: myPlane.position.y - myPlane.size.height / 2)
        
        // Adding to gameplay health attributes
        healthLabel.text = "Health: \(health)"
        
        // Changes health label red if too low
        if (health <= 3) {
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
        
        var firstBody: SKPhysicsBody //= contact.bodyA.node as! SKSpriteNode
        var secondBody: SKPhysicsBody //= contact.bodyB.node as! SKSpriteNode
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if((firstBody.categoryBitMask == 1) && (secondBody.categoryBitMask == 4)) {
            secondBody.node?.removeFromParent()
        }
        
//        if ((firstBody.name == "MyPlane") && (secondBody.name == "Ground")) {
//            didMyPlaneHitGround(firstBody, Ground: secondBody)
//        } else if ((firstBody.name == "Ground") && (secondBody.name == "MyPlane")) {
//            didMyPlaneHitGround(secondBody, Ground: firstBody)
//        }
//        else if ((firstBody.name == "MyPlane") && (secondBody.name == "Enemy")) {
//            didMyPlaneHitEnemy(firstBody, Enemy: secondBody)
//        } else if ((firstBody.name == "Enemy") && (secondBody.name == "MyPlane")) {
//            didMyPlaneHitEnemy(secondBody, Enemy: firstBody)
//        }
//        else if ((firstBody.name == "MyPlane") && (secondBody.name == "PowerUp")) {
//            didMyPlaneHitPowerUp(firstBody, PowerUp: secondBody)
//        } else if ((firstBody.name == "PowerUp") && (secondBody.name == "MyPlane")) {
//            didMyPlaneHitPowerUp(secondBody, PowerUp: firstBody)
//        }
//        else if ((firstBody.name == "MyBullets") && (secondBody.name == "Enemy")) {
//            didBulletsHitEnemy(firstBody, Enemy: secondBody)
//        } else if ((firstBody.name == "Enemy") && (secondBody.name == "MyBullets")) {
//            didBulletsHitEnemy(secondBody, Enemy: firstBody)
//        }
//        else if ((firstBody.name == "MyBullets") && (secondBody.name == "Cloud")) {
//            didBulletsHitCloud(firstBody, Cloud: secondBody)
//        } else if ((firstBody.name == "Cloud") && (secondBody.name == "MyBullets")) {
//            didBulletsHitCloud(secondBody, Cloud: firstBody)
//        }
//        else if ((firstBody.name == "MyBullets") && (secondBody.name == "PowerUp")) {
//            didBulletsHitPowerUp(firstBody, PowerUp: secondBody)
//        } else if ((firstBody.name == "PowerUp") && (secondBody.name == "MyBullets")) {
//            didBulletsHitPowerUp(secondBody, PowerUp: firstBody)
//        }
//        else if ((firstBody.name == "EnemyFire") && (secondBody.name == "MyPlane")) {
//            didEnemyFireHitMyPlane(firstBody, MyPlane: secondBody)
//        } else if ((firstBody.name == "MyPlane") && (secondBody.name == "EnemyFire")) {
//            didEnemyFireHitMyPlane(secondBody, MyPlane: firstBody)
//        }
//        else if ((firstBody.name == "SkyBombs") && (secondBody.name == "MyPlane")) {
//            didSkyBombHitMyPlane(firstBody, MyPlane: secondBody)
//        } else if ((firstBody.name == "MyPlane") && (secondBody.name == "SkyBombs")) {
//            didSkyBombHitMyPlane(secondBody, MyPlane: firstBody)
//        }
//        else if ((firstBody.name == "SkyBombs") && (secondBody.name == "Enemy")) {
//            didSkyBombHitEnemy(firstBody, Enemy: secondBody)
//        } else if ((firstBody.name == "Enemy") && (secondBody.name == "SkyBombs")) {
//            didSkyBombHitEnemy(secondBody, Enemy: firstBody)
//        }
//        else if ((firstBody.name == "MyPlane") && (secondBody.name == "PowerUp")) {
//            didMyPlaneHitPowerUp(firstBody, PowerUp: secondBody)
//        } else if ((firstBody.name == "PowerUp") && (secondBody.name == "MyPlane")) {
//            didMyPlaneHitPowerUp(secondBody, PowerUp: firstBody)
//        }
//        else if ((firstBody.name == "MyBullets") && (secondBody.name == "PowerUp")) {
//            didBulletsHitPowerUp(firstBody, PowerUp: secondBody)
//        } else if ((firstBody.name == "PowerUp") && (secondBody.name == "MyBullets")) {
//            didBulletsHitPowerUp(secondBody, PowerUp: firstBody)
//        }

    }
    
    
    /**************************** Collision Functions ********************************/
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
        
        crashSound = SKAudioNode(fileNamed: "crash")
        crashSound.runAction(SKAction.play())
        crashSound.autoplayLooped = false
        
        self.addChild(crashSound)
        
        // GAME OVER
    }
    
    // Function if player hit enemy or enemy hits player
//    func didMyPlaneHitEnemy(MyPlane: SKSpriteNode, Enemy: SKSpriteNode) {
//        explosion = SKEmitterNode(fileNamed: "FireExplosion")
//        smoke = SKEmitterNode(fileNamed: "Smoke")
//        
//        explosion.position = Enemy.position
//        smoke.position = Enemy.position
//        
//        Enemy.removeFromParent()
//        MyPlane.removeFromParent()
//        self.addChild(explosion)
//        self.addChild(smoke)
//        
//        crashSound = SKAudioNode(fileNamed: "crash")
//        crashSound.runAction(SKAction.play())
//        crashSound.autoplayLooped = false
//        
//        self.addChild(crashSound)
//        
//        health -= 10
//        score -= 10
//    }
//    
//    // Function if player hits star
//    func didMyPlaneHitPowerUp(MyPlane: SKSpriteNode, PowerUp: SKSpriteNode) {
//        // The star will emit a spark and sound when hit
//        explode = SKEmitterNode(fileNamed: "Explode")
//        explode.position = PowerUp.position
//        
//        self.addChild(explode)
//        
//        // Adds star to make sound
//        PowerUp.removeFromParent()
//        
//        // Calling pre-loaded sound to the star hits
//        powerUpSound = SKAudioNode(fileNamed: "powerUp")
//        powerUpSound.runAction(SKAction.play())
//        powerUpSound.autoplayLooped = false
//        
//        self.addChild(powerUpSound)
//        
//        // Points per star added to score and health
//        score += 5
//        health += 10
//        powerUpCount += 1
//    }
//    
//    // Function if player hits enemy with weapon
//    func didBulletsHitEnemy (MyBullets: SKSpriteNode, Enemy: SKSpriteNode) {
//        explosion = SKEmitterNode(fileNamed: "FireExplosion")
//        smoke = SKEmitterNode(fileNamed: "Smoke")
//        
//        explosion.position = Enemy.position
//        smoke.position = Enemy.position
//        
//        Enemy.removeFromParent()
//        MyBullets.removeFromParent()
//        self.addChild(explosion)
//        self.addChild(smoke)
//        
//        crashSound = SKAudioNode(fileNamed: "crash")
//        crashSound.runAction(SKAction.play())
//        crashSound.autoplayLooped = false
//        
//        self.addChild(crashSound)
//        
//        // Hitting an the enemy adds score and health
//        score += 10
//        health += 2
//    }
//    
//    // Function if player hits star with bullets
//    func didBulletsHitPowerUp(MyBullets: SKSpriteNode, PowerUp: SKSpriteNode) {
//        // The star will emit a spark and sound when hit
//        explode = SKEmitterNode(fileNamed: "Explode")
//        explode.position = PowerUp.position
//        self.addChild(explode)
//        
//        // Adds star to make sound
//        PowerUp.removeFromParent()
//        MyBullets.removeFromParent()
//        
//        // Calling pre-loaded sound to the star hits
//        powerUpSound = SKAudioNode(fileNamed: "powerUp")
//        powerUpSound.runAction(SKAction.play())
//        powerUpSound.autoplayLooped = false
//        
//        self.addChild(powerUpSound)
//        
//        // Points per star added to score and 1 health
//        score += 5
//        health += 10
//        powerUpCount += 1
//    }
//    
//    // Function if player hit cloud with weapon
//    func didBulletsHitCloud (MyBullets: SKSpriteNode, Cloud: SKSpriteNode) {
//        rain = SKEmitterNode(fileNamed: "Rain")
//        rain.position = Cloud.position
//        rain.position = CGPointMake(badCloud.position.x, badCloud.position.y)
//        
//        MyBullets.removeFromParent()
//        
//        // Influenced by plane's movement
//        rain.targetNode = self.scene
//        badCloud.addChild(rain)
//    }
//    
//    // Function if player hit enemy or enemy hits player
//    func didEnemyFireHitMyPlane (EnemyFire: SKSpriteNode, MyPlane: SKSpriteNode) {
//        explosion = SKEmitterNode(fileNamed: "FireExplosion")
//        smoke = SKEmitterNode(fileNamed: "Smoke")
//        
//        explosion.position = MyPlane.position
//        smoke.position = MyPlane.position
//        
//        EnemyFire.removeFromParent()
//        MyPlane.removeFromParent()
//        gunfire.removeFromParent()
//        self.addChild(explosion)
//        self.addChild(smoke)
//        
//        crashSound = SKAudioNode(fileNamed: "crash")
//        crashSound.runAction(SKAction.play())
//        crashSound.autoplayLooped = false
//        
//        self.addChild(crashSound)
//        
//        health -= 5
//    }
//    
//    // Function if player hit enemy or enemy hits player
//    func didEnemyFireHitEnemy (EnemyFire: SKSpriteNode, Enemy: SKSpriteNode) {
//        explosion = SKEmitterNode(fileNamed: "FireExplosion")
//        smoke = SKEmitterNode(fileNamed: "Smoke")
//        
//        explosion.position = Enemy.position
//        smoke.position = Enemy.position
//        
//        EnemyFire.removeFromParent()
//        Enemy.removeFromParent()
//        gunfire.removeFromParent()
//        self.addChild(explosion)
//        self.addChild(smoke)
//        
//        crashSound = SKAudioNode(fileNamed: "crash")
//        crashSound.runAction(SKAction.play())
//        crashSound.autoplayLooped = false
//        
//        self.addChild(crashSound)
//        
//        // We get points when enemy shoots themselves
//        score += 3
//    }
//    
//    // Function if sky bomb hits enemy
//    func didSkyBombHitEnemy (SkyBomb: SKSpriteNode, Enemy: SKSpriteNode) {
//        explosion = SKEmitterNode(fileNamed: "FireExplosion")
//        smoke = SKEmitterNode(fileNamed: "Smoke")
//        
//        explosion.position = Enemy.position
//        smoke.position = Enemy.position
//        
//        self.addChild(explosion)
//        self.addChild(smoke)
//        
//        crashSound = SKAudioNode(fileNamed: "crash")
//        crashSound.runAction(SKAction.play())
//        crashSound.autoplayLooped = false
//        
//        self.addChild(crashSound)
//    }
//    
//    // Function if sky bomb hits enemy
//    func didSkyBombHitMyPlane (SkyBomb: SKSpriteNode, MyPlane: SKSpriteNode) {
//        explosion = SKEmitterNode(fileNamed: "FireExplosion")
//        smoke = SKEmitterNode(fileNamed: "Smoke")
//        
//        explosion.position = MyPlane.position
//        smoke.position = MyPlane.position
//        
//        self.addChild(explosion)
//        self.addChild(smoke)
//        
//        crashSound = SKAudioNode(fileNamed: "crash")
//        crashSound.runAction(SKAction.play())
//        crashSound.autoplayLooped = false
//        
//        self.addChild(crashSound)
//        
//        // Skybomb takes away health
//        health -= 5
//        
//        playerHP = max(0, health - 20)
//    }

    
    /********************************* Background Functions *********************************/
    // MARK: - Background Functions
    
    let myBackgroundNode = SKNode()
    
    // Adding scrolling background
    func createBackground() -> SKNode {
        
        // Default to texture:
        let myBackground = SKTexture(imageNamed: "clouds")
        
        for i in 0...1 {
            
            let background = SKSpriteNode(texture: myBackground)
            background.name = "Background"
            background.size = self.frame.size
            background.zPosition = 1
            myBackgroundNode.position = CGPoint(x: (myBackground.size().width * CGFloat(i)) - CGFloat(1 * i), y: 0)
            
            myBackgroundNode.addChild(background)
        }
        return myBackgroundNode
    }
    
    // Puts createMyBackground in motion
    func moveBackground() {
        
        self.enumerateChildNodesWithName("Background", usingBlock: ({
            (node, error) in
            
                node.position.x -= 0.5
            
            if node.position.x < -((self.scene?.size.width)!) {
                
                node.position.x += (self.scene?.size.width)! * 2
            }
        }))
    }
    
    let midgroundNode = SKNode()
    
    // Adding scrolling midground
    func createMidground() -> SKNode {
        
        let midground = SKTexture(imageNamed: "mountains")
        
        for i in 0...1 {
            
            let ground = SKSpriteNode(texture: midground)
            ground.name = "Midground"
            ground.zPosition = 5
            midgroundNode.position = CGPoint(x: (midground.size().width / 2.0 + (midground.size().width * CGFloat(i))), y: midground.size().height / 2)
//            ground.size = CGSize(width: self.frame.size.width, height: 454)
        
            midgroundNode.addChild(ground)
        }
        return midgroundNode
    }
    
    // Puts createMyMidground in motion
    func moveMidground() {
        
        self.enumerateChildNodesWithName("Midground", usingBlock: ({
            (node, error) in
            
            node.position.x -= 1.0
            
            if node.position.x < -((self.scene?.size.width)!) {
                
                node.position.x += (self.scene?.size.width)! * 2
            }
        }))
    }
    
    let foregroundNode = SKNode()
    
    // Adding scrolling foreground
    func createForeground() -> SKNode {
        
        let foreground = SKTexture(imageNamed: "lonelytree")
        
        for i in 0...1 {
            
            let ground = SKSpriteNode(texture: foreground)
            ground.name = "Ground"
            ground.zPosition = 10
            foregroundNode.position = CGPoint(x: (foreground.size().width / 2 + (foreground.size().width * CGFloat(i))), y: foreground.size().height / 2)
//            ground.size = CGSize(width: self.frame.size.width, height: 400)
            foregroundNode.addChild(ground)
            
            // Create physics body
            ground.physicsBody?.dynamic = false
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
            ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
            ground.physicsBody?.collisionBitMask = PhysicsCategory.MyPlane
            ground.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane
        }
        return foregroundNode
    }

    // Puts createMyForeground in motion
    func moveForeground() {
        
        self.enumerateChildNodesWithName("Foreground", usingBlock: ({
            (node, error) in
            
            node.position.x -= 2.0
            
            if node.position.x < -((self.scene?.size.width)!) {
                
                node.position.x += (self.scene?.size.width)! * 2
            }
        }))
    }
    
    
    /*********************************** Animation Functions *********************************/
    // MARK: - Plane animation functions
    
    // Creating node for sprite
    let myPlaneNode = SKNode()
    
    func createPlane() -> SKNode {
        
        // Loop to run through .png's for animation
        for i in 1...2 { //planeAtlas.textureNames.count {
            let plane = "MyFokker\(i)"
            animationFrames.append(SKTexture(imageNamed: plane))
        }
        
        // Add user's animated bi-plane
        myPlane = SKSpriteNode(imageNamed: airplanesAtlas.textureNames[0])
        myPlaneNode.position = CGPoint(x: self.size.width / 6, y: self.size.height / 2)
        myPlane.zPosition = 11
        myPlane.setScale(0.4)
        
        myPlaneNode.addChild(myPlane)
        
        // Body physics of player's plane
        myPlane.name = "MyPlane"
        myPlane.physicsBody?.affectedByGravity = false
        myPlane.physicsBody?.dynamic = false
        myPlane.physicsBody = SKPhysicsBody(rectangleOfSize: myPlane.size)
        myPlane.physicsBody?.categoryBitMask = PhysicsCategory.MyPlane
        myPlane.physicsBody?.collisionBitMask = PhysicsCategory.Cloud
        myPlane.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Enemy | PhysicsCategory.EnemyFire | PhysicsCategory.SkyBombs | PhysicsCategory.PowerUp | PhysicsCategory.Coins
        
        // Create the animation
        let flyAction = SKAction.animateWithTextures(animationFrames, timePerFrame: 0.2)
        animation = SKAction.repeatActionForever(flyAction)
        myPlane.runAction(animation)
        
        return myPlaneNode
    }
    
    
    /*********************************** Spawning Functions *********************************/
    // MARK: - Spawning Functions
    
    // Creating node for sprite
    let bulletsNode = SKNode()
    
    // Spawn bullets for player's plane
    func spawnBullets() -> SKNode {
        
        // Setup bullet node
        bullets = SKSpriteNode(imageNamed: "Bullet")
        bullets.name = "MyBullets"
        bulletsNode.position = CGPoint(x: myPlane.position.x + 50, y: myPlane.position.y)
        bullets.zPosition = 10
        bulletsNode.zPosition = -10
        bullets.setScale(0.2)
        
        bulletsNode.addChild(bullets)
        
        // Body physics of player's bullets
        bullets.physicsBody = SKPhysicsBody(rectangleOfSize: bullets.size)
        bullets.physicsBody?.usesPreciseCollisionDetection = true
        bullets.physicsBody?.dynamic = false
        bullets.physicsBody?.affectedByGravity = false
        bullets.physicsBody?.categoryBitMask = PhysicsCategory.MyBullets
        bullets.physicsBody?.collisionBitMask = PhysicsCategory.Enemy | PhysicsCategory.PowerUp | PhysicsCategory.Coins
        bullets.physicsBody?.contactTestBitMask = bullets.physicsBody!.collisionBitMask | PhysicsCategory.Enemy | PhysicsCategory.PowerUp | PhysicsCategory.Coins
        
        // Shoot em up!
        let action = SKAction.moveToX(self.size.width + 150, duration: 0.7)
        let actionDone = SKAction.removeFromParent()
        bullets.runAction(SKAction.sequence([action, actionDone]))
        
        return bulletsNode
    }
    
    let wingmenNode = SKNode()
    
    // Adding ally forces in background
    func spawnWingmen() -> SKNode {
        
        // Loop to run through .png's for animation
        for i in 1...allyAtlas.textureNames.count {
            let plane = "Ally1_\(i)"
            animationFrames.append(SKTexture(imageNamed: plane))
        }
        
        for i in 1...ally2Atlas.textureNames.count {
            let planes = "Ally2_\(i)"
            animationFrames.append(SKTexture(imageNamed: planes))
        }
        
        myAlly.setScale(0.2)
        myAlly2.setScale(0.15)
        
        // Array of 2 sets of allies
        let myAllies = [myAlly, myAlly2]
        
        // Add user's animated bi-plane
        myAlly = SKSpriteNode(imageNamed: allyAtlas.textureNames[0])
        myAlly2 = SKSpriteNode(imageNamed: ally2Atlas.textureNames[0])
        
        for ally in myAllies {
            
            // Calculate random spawn points for allies
            let random = CGFloat(arc4random_uniform(1900)/4)
            wingmenNode.position = CGPoint(x: -self.size.width, y: random)
            
            // Create the animation
            let flyAction = SKAction.animateWithTextures(animationFrames, timePerFrame: 0.2)
            animation = SKAction.repeatActionForever(flyAction)
            ally.runAction(animation)
            
            // Move bomber forward
            let action = SKAction.moveToX(self.size.width + 100, duration: 12.0)
            let actionDone = SKAction.removeFromParent()
            ally.runAction(SKAction.sequence([action, actionDone]))
            
            wingmenNode.addChild(ally)
            
            // Body physics for ally
            ally.physicsBody = SKPhysicsBody(rectangleOfSize: myAlly.size)
            ally.physicsBody?.affectedByGravity = false
            ally.physicsBody?.dynamic = false
            
            // Add sound
            propSound = SKAudioNode(fileNamed: "prop")
            propSound.runAction(SKAction.play())
            propSound.autoplayLooped = false
            ally.addChild(propSound)
        }
        return wingmenNode
    }
    
    // Creating node for sprite
    let skyEnemyNode = SKNode()
    
    // Generate enemy fighter planes
    func spawnEnemyPlane() -> SKNode {

        // Loop to run through .png's for animation
        for i in 1...2 {
            let plane = "Enemy_attack_\(i)"
            animationFrames.append(SKTexture(imageNamed: plane))
        }
        
        // Add user's animated bi-plane
        skyEnemy = SKSpriteNode(imageNamed: enemyPlanesAtlas.textureNames[0])
        skyEnemy.setScale(0.4)
        skyEnemy.zPosition = 9
        
        // Calculate random spawn points for air enemies
        skyEnemy.position = CGPoint(x: self.size.width, y: CGFloat(arc4random_uniform(700) + 250))
        skyEnemy.xScale = node.xScale * -1
        
        skyEnemyNode.addChild(skyEnemy)
        
        // Body physics for enemy's planes
        skyEnemy.physicsBody = SKPhysicsBody(rectangleOfSize: skyEnemy.size)
        skyEnemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        skyEnemy.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane | PhysicsCategory.MyBullets | PhysicsCategory.Enemy | PhysicsCategory.EnemyFire | PhysicsCategory.SkyBombs
        skyEnemy.physicsBody?.collisionBitMask = PhysicsCategory.MyPlane | PhysicsCategory.MyBullets | PhysicsCategory.Enemy | PhysicsCategory.EnemyFire | PhysicsCategory.SkyBombs | PhysicsCategory.Cloud
        skyEnemy.name = "Enemy"
        skyEnemy.physicsBody?.dynamic = false
        skyEnemy.physicsBody?.affectedByGravity = false

        // Create the animation
        let flyAction = SKAction.animateWithTextures(animationFrames, timePerFrame: 3.0)
        animation = SKAction.repeatActionForever(flyAction)
        myPlane.runAction(animation)
        
        // Move enemies forward
        let action = SKAction.moveToX(-200, duration: 4.0)
        let actionDone = SKAction.removeFromParent()
        skyEnemy.runAction(SKAction.sequence([action, actionDone]))
        
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
        
        return skyEnemyNode
    }

    let enemyFireNode = SKNode()
    
    func spawnEnemyFire() -> SKNode {
        let enemyFire = SKSpriteNode(imageNamed: "Bullet")
        enemyFire.setScale(0.2)
        enemyFire.zPosition = 9
        enemyFire.xScale = node.xScale * -1
        enemyFireNode.position = CGPointMake(skyEnemy.position.x - 75, skyEnemy.position.y)
        
        enemyFire.addChild(enemyFireNode) // Generate enemy fire

        // Body physics of player's bullets
        enemyFire.physicsBody = SKPhysicsBody(rectangleOfSize: enemyFire.size)
        enemyFire.physicsBody?.categoryBitMask = PhysicsCategory.EnemyFire
        enemyFire.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane | PhysicsCategory.Enemy | PhysicsCategory.MyBullets | PhysicsCategory.Coins
        enemyFire.physicsBody?.collisionBitMask = PhysicsCategory.MyPlane | PhysicsCategory.Enemy | PhysicsCategory.MyBullets | PhysicsCategory.Cloud | PhysicsCategory.PowerUp
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
        
        return enemyFireNode
    }
    
    let skyExplosionNode = SKNode()
    
    func skyExplosions() -> SKNode {
        
        // Sky explosions of a normal battle
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        explosion.particleLifetime = 0.5
        explosion.particleScale = 0.4
        explosion.particleSpeed = 1.5
        explosion.zPosition = 9
        
        let xPos = randomBetweenNumbers(0, secondNum: frame.width )
        
        // Sky bomb position on screen
        skyEnemyNode.position = CGPoint(x: xPos, y: self.frame.size.height * 0.25)
        skyExplosionNode.addChild(explode)
        
        // Physics for sky bomb
        explosion.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        explosion.physicsBody?.categoryBitMask = PhysicsCategory.SkyBombs
        explosion.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane | PhysicsCategory.Enemy
        explosion.physicsBody?.collisionBitMask = PhysicsCategory.MyPlane | PhysicsCategory.Enemy
        explosion.name = "SkyBomb"
        explosion.physicsBody?.dynamic = false
        explosion.physicsBody?.affectedByGravity = false
        
        skyBoomSound = SKAudioNode(fileNamed: "skyBoom")
        skyBoomSound.runAction(SKAction.play())
        skyBoomSound.autoplayLooped = false
        self.addChild(skyBoomSound)
        
        return skyExplosionNode
    }
    
    let paraTroopNode = SKNode()
    
    func paratrooperJump() -> SKNode {
        
        // Jumping for their lives!
        paratrooper = SKSpriteNode(imageNamed: "paratrooper")
        paratrooper.setScale(0.75)
        paratrooper.zPosition = 7
        
        let xPos = randomBetweenNumbers(0, secondNum: frame.width )
        
        // Paratrooper position on screen
        paraTroopNode.position = CGPoint(x: xPos, y: self.frame.size.height * 0.25)
        
        paraTroopNode.addChild(paratrooper)
        
        // Physics for paratrooper
        paratrooper.physicsBody?.affectedByGravity = false
        paratrooper.physicsBody?.dynamic = true
        
        // Move enemies forward
        let action = SKAction.moveToY(-70, duration: 10.0)
        let actionDone = SKAction.removeFromParent()
        paratrooper.runAction(SKAction.sequence([action, actionDone]))
        
        return paraTroopNode
    }
    
    let powerUpNode = SKNode()
    
    // Spawning a bonus star
    func spawnPowerUps() -> SKNode {
        
        // Loop to run through .png's for animation
        for i in 1...assetsAtlas.textureNames.count {
            let powerUp = "life_power_up_\(i)"
            animationFrames.append(SKTexture(imageNamed: powerUp))
        }
        
        // Add user's animated powerUp
        powerUp = SKSpriteNode(imageNamed: assetsAtlas.textureNames[0])
        powerUp.runAction(pulseAnimation)
        
        let xPos = randomBetweenNumbers(0, secondNum: frame.width )
        
        // Star position off screen
        powerUpNode.position = CGPoint(x: xPos, y: self.frame.size.height * 0.25)
        powerUp.setScale(3.0)
        powerUp.zPosition = 11
        
        powerUpNode.addChild(powerUp)
        
        // Added star's physics
        powerUp.physicsBody = SKPhysicsBody(edgeLoopFromRect: powerUp.frame)
        powerUp.physicsBody?.categoryBitMask = PhysicsCategory.PowerUp
        powerUp.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane | PhysicsCategory.MyBullets | PhysicsCategory.Enemy | PhysicsCategory.EnemyFire
        powerUp.physicsBody?.collisionBitMask = PhysicsCategory.MyBullets | PhysicsCategory.EnemyFire
        powerUp.physicsBody?.dynamic = false
        powerUp.physicsBody?.affectedByGravity = false
        
        // Add sound
        powerUpSound = SKAudioNode(fileNamed: "powerUp")
        powerUpSound.runAction(SKAction.play())
        powerUpSound.autoplayLooped = false
        self.addChild(powerUpSound)
        
        return powerUpNode
//        createAnimations()
    }
    
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
//    // Animation for star
//    func createAnimations() {
//        
//        // Scale the star smaller and fade it slightly:
//        let pulseOutGroup = SKAction.group([
//            SKAction.fadeAlphaTo(0.85, duration: 0.8),
//            SKAction.scaleTo(0.6, duration: 0.8),
//            SKAction.rotateByAngle(-0.3, duration: 0.8)
//            ])
//        
//        // Push the star big again, and fade it back in:
//        let pulseInGroup = SKAction.group([
//            SKAction.fadeAlphaTo(1, duration: 1.5),
//            SKAction.scaleTo(1, duration: 1.5),
//            SKAction.rotateByAngle(3.5, duration: 1.5)
//            ])
//        
//        // Combine the two into a sequence:
//        let pulseSequence = SKAction.sequence([pulseOutGroup, pulseInGroup])
//        pulseAnimation = SKAction.repeatActionForever(pulseSequence)
//    }
    
    let cloudNode = SKNode()
    
    // Introducing the cloud using linear interpolation
    func cloudOnAPath() -> SKNode {
        
        badCloud = SKSpriteNode(imageNamed: "badCloud")
        badCloud.zPosition = 4
        badCloud.setScale(0.3)
        
        // Randomly place cloud on Y axis
        let actualY = CGFloat.random(min: 400, max: self.frame.size.height - 100)
        
        // Clouds position off screen
        cloudNode.position = CGPoint(x: size.width + badCloud.size.width / 2, y: actualY)
        
        // This time I will determine speed by velocity rather than time interval
        let actualDuration = CGFloat.random(min: CGFloat(10.0), max: CGFloat(15.0))
        
        cloudNode.addChild(badCloud) // Generate "bonus" star
        
        // Added cloud's physics
        badCloud.physicsBody = SKPhysicsBody(edgeLoopFromRect: badCloud.frame)
        badCloud.physicsBody?.categoryBitMask = PhysicsCategory.Cloud 
        badCloud.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane | PhysicsCategory.MyBullets
        badCloud.physicsBody?.collisionBitMask = PhysicsCategory.MyBullets | PhysicsCategory.MyPlane
        badCloud.name = "Cloud"
        badCloud.physicsBody?.dynamic = false
        badCloud.physicsBody?.affectedByGravity = false
        
        // Create a path func cloudOnAPath() {
        let actionMove = SKAction.moveTo(CGPoint(x: -badCloud.size.width / 2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        badCloud.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        badCloud.shadowCastBitMask = 1
        badCloud.lightingBitMask = 0
        
        return cloudNode
    }
    

    /*********************************** Emitter Functions *********************************/
    // MARK: - Emitter Functions
    
    // Add emitter of exhaust smoke behind plane
//    func addSmokeTrail() {
//        
//        // Create smoke trail for myPlane
//        smokeTrail = SKEmitterNode(fileNamed: "SmokeTrail")
//        smokeTrail.particleScale = 1.2
//        
//        // Influenced by plane's movement
//        smokeTrail.targetNode = self.scene
//        myPlane.addChild(smokeTrail)
//    }
    
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
        display = SKSpriteNode(color: UIColor.blackColor(), size: CGSizeMake(self.size.width, self.size.height * 0.06))
        display.anchorPoint = CGPointMake(0, 0)
        display.position = CGPointMake(0, self.size.height - display.size.height)
        display.zPosition = 15
        
        // Pause button container
        pauseNode.position = CGPoint(x: display.size.width / 2, y: display.size.height / 2)
        pauseNode.size = CGSizeMake(display.size.height * 3, display.size.height * 2.5)
        pauseNode.name = "PauseButtonContainer"
        
        // Pause button
        pauseButton = SKSpriteNode(imageNamed: "pause")
        pauseButton.zPosition = 1000
        pauseButton.size = CGSize(width: 30.0, height: 30.0)
        pauseButton.position = CGPoint(x: display.size.width / 2, y: display.size.height / 2 - 5)
        pauseButton.name = "PauseButton"
        
        // Health label
        healthLabel = SKLabelNode(fontNamed: "gaurdianpi")
        health = 20
        healthLabel.text = "Health: \(health)"
        healthLabel.fontSize = display.size.height
        healthLabel.fontColor = SKColor.whiteColor()
        healthLabel.position = CGPoint(x: 25, y: display.size.height / 2 - 10)
        healthLabel.horizontalAlignmentMode = .Left
        healthLabel.zPosition = 15
        
        // Power Up Health Hearts
        powerUp = SKSpriteNode(imageNamed: "life_power_up_1")
        powerUp.zPosition = 100
        powerUp.size = CGSize(width: 30, height: 30)
        powerUp.position = CGPoint(x: 25, y: display.size.height / 2 - 50)
        powerUp.name = "PowerUp"
        
        // Label to let user know the count of power ups
        powerUpLabel = SKLabelNode(fontNamed: "gaurdianpi")
        powerUpLabel.zPosition = 100
        powerUpCount = 0
        powerUpLabel.color = UIColor.redColor()
        powerUpLabel.text = " X \(powerUpCount)"
        powerUpLabel.fontSize = powerUp.size.height
        powerUpLabel.position = CGPoint(x: powerUp.frame.width + 75, y: display.size.height / 2 - 50)
        
        // Score label
        scoreLabel = SKLabelNode(fontNamed: "gaurdianpi")
        score = 0
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = display.size.height
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.position = CGPoint(x: display.size.width - 25, y: display.size.height / 2 - 10)
        scoreLabel.horizontalAlignmentMode = .Right
        scoreLabel.zPosition = 15
        
        // Coin Image
        coinImage = SKSpriteNode(imageNamed: "Coin_1")
        coinImage.zPosition = 200
        coinImage.size = CGSize(width: 30, height: 30)
        coinImage.position = CGPoint(x: display.size.width - 50, y: display.size.height / 2 - 50)
        coinImage.name = "Coin"
        
        // Label to let user know the count of coins collected
        coinCountLbl = SKLabelNode(fontNamed: "gaurdianpi")
        coinCountLbl.zPosition = 200
        coinCount = 0
        coinCountLbl.color = UIColor.yellowColor()
        coinCountLbl.text = " X \(coinCount)"
        coinCountLbl.fontSize = powerUp.size.height
        coinCountLbl.position = CGPoint(x: powerUp.frame.width + 10, y: display.size.height / 2 - 50)
        
        self.addChild(display)
        display.addChild(pauseNode)
        display.addChild(pauseButton)
        display.addChild(healthLabel)
        display.addChild(powerUp)
        display.addChild(powerUpLabel)
        display.addChild(scoreLabel)
        display.addChild(coinImage)
        display.addChild(coinCountLbl)
    }
    
//    func holdGame() {
//        
//        // Stop movement, fade out, move to center, fade in
//        self.removeAllActions()
//        self.myPlane.runAction(SKAction.fadeOutWithDuration(1) , completion: {
//            self.myPlane.position = CGPointMake(self.size.width / 2, self.size.height / 2)
//            self.myPlane.runAction(SKAction.fadeInWithDuration(1), completion: {
//                self.gamePaused = false
//            })
//        })
//    }
    
    
    /******************************* Healthbar GUI Function *********************************/
    // MARK: - Healthbar GUI Function
    
    // Healthbar function for visual display
    func updateHealthBar(node: SKSpriteNode, withHealthPoints hp: Int) {
        
        let barSize = CGSize(width: myPlane.size.width, height: myPlane.size.height / 10)
        
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
