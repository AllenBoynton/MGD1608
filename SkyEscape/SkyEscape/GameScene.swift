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
    static let Ground1     : UInt32 = 1    //0x1 << 0
    static let MyBullets2  : UInt32 = 2    //0x1 << 1
    static let MyBombs4    : UInt32 = 4    //0x1 << 2
    static let Player8     : UInt32 = 8    //0x1 << 3
    static let Enemy16     : UInt32 = 16   //0x1 << 4
    static let Tank32      : UInt32 = 32   //0x1 << 5
    static let EnemyFire64 : UInt32 = 64   //0x1 << 6
    static let Missiles128 : UInt32 = 128  //0x1 << 7
    static let Cloud256    : UInt32 = 256  //0x1 << 8
    static let StarMask512 : UInt32 = 512  //0x1 << 9
    static let Coins1024   : UInt32 = 1024 //0x1 << 10
    static let Rain2048    : UInt32 = 2048 //0x1 << 11
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
var startGameSound = SKAudioNode()
var biplaneFlyingSound = SKAudioNode()
var gunfireSound = SKAudioNode()
var starSound = SKAudioNode()
var coinSound = SKAudioNode()
var thunderSound = SKAudioNode()
var crashSound = SKAudioNode()
var bombSound = SKAudioNode()
var bombDropSound = SKAudioNode()
var planesFightSound = SKAudioNode()
var bGCannonsSound = SKAudioNode()
var planeMGunSound = SKAudioNode()
var tankSound = SKAudioNode()
var tankFiringSound = SKAudioNode()
var airplaneFlyBySound = SKAudioNode()
var airplaneP51Sound = SKAudioNode()


let maxHealth = 100
let healthBarWidth: CGFloat = 40
let healthBarHeight: CGFloat = 4
let playerHealthBar = SKSpriteNode()

let darkenOpacity: CGFloat = 0.8
let darkenDuration: CFTimeInterval = 2


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var pulseAnimation = SKAction()
    
    // Location for touch screen
    var touchLocation = CGPointZero
    
    // Main background
    var myBackground = SKSpriteNode()
    
    // Mid background
    var midground1 = SKSpriteNode()
    var midground2 = SKSpriteNode()
    var mtHeight = CGFloat(200)
    
    // Foreground
    var foreground = SKSpriteNode()
    
    // MyPlane animation setup
    var myPlane = SKSpriteNode()
    var planeArray = [SKTexture]()
    var planeAtlas: SKTextureAtlas =
        SKTextureAtlas(named: "Images.atlas")
    
    // Sky nodes
    var badCloud = SKSpriteNode()
    var star = SKSpriteNode()
    var bronzeCoin = SKSpriteNode()
    var goldCoin = SKSpriteNode()
    
    // Player's weapons
    var bullets = SKSpriteNode()
    var bombs = SKSpriteNode()
    var bomber = SKSpriteNode(imageNamed: "bomber")
    var wingman = SKSpriteNode(imageNamed: "wingman")
    
    // Enemy planes / Ground / weapons
    var enemy1 = SKSpriteNode(imageNamed: "enemy1")
    var enemy2 = SKSpriteNode(imageNamed: "enemy2")
    var enemy3 = SKSpriteNode(imageNamed: "enemy3")
    var enemy4 = SKSpriteNode(imageNamed: "enemy4")
    var enemyArray: [SKSpriteNode] = []
    var randomEnemy = SKSpriteNode()
    var enemyFire = SKSpriteNode()
    var tank = SKSpriteNode()
    var missiles = SKSpriteNode()
    
    // Timers for spawn / interval / delays
    var timer = NSTimer()
    var starTimer = NSTimer()
    var wingTimer = NSTimer()
    var enemyTimer = NSTimer()
    var enemyShoots = NSTimer()
    var cloudTimer  = NSTimer()
    var enemyTankTimer  = NSTimer()
    var enemyTankShoots = NSTimer()
    
    // Game metering GUI
    var score = 0
    var starCount = 0
    var health = 10
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
    var darkenLayer: SKSpriteNode?
    var gameOverLabel: SKLabelNode?
    var gamePaused = false
    
    // NSDate formatting
    
    
    /********************************** didMoveToView Function **********************************/
    // MARK: - didMoveToView
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // Sets the physics delegate and physics body
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        physicsWorld.contactDelegate = self // Physics delegate set
        
        // Added HUD with PAUSE
        createHUD()
        
                
    /********************************* Adding Scroll Background *********************************/
    // MARK: - Scroll Background
        
        // Adding scrolling Main Background
        createBackground()
        
        // Adding scrolling midground
        createMidground()
        
        // Adding scrolling foreground
        createForeground()
        
    /*************************************** Spawning Nodes *************************************/
    // MARK: - Spawning
        
        // Adding our player's plane to the scene
        animateMyPlane()
        
        // Add background wingmen planes
        spawnWingman()
        
        // Adding the bronze coin - value = 1
//        bronzeCoin.spawn(world, position: CGPoint(x: 490, y: 250))
        
        // Adding the gold coin - value = 5
//        goldCoin.spawn(world, position: CGPoint(x: 460, y: 250))
//        goldCoin.turnToGold()
        
        // Spawning random points for air enemies
        spawnEnemyPlane()
        spawnEnemyFire()
        
        // Spawning the tank
        spawnTank()
        
        // Spawning the missiles for enemy tank
        spawnTankMissiles()
        
        // Put bad cloud on a linear interpolation path
        runAction(SKAction.repeatActionForever(SKAction.sequence([
                SKAction.runBlock(cloudOnAPath),
                SKAction.waitForDuration(12.0)
                ])
            ))
        
        // Add the spawning star:
        spawnStar()
        
        // Initilize values and labels
        initializeValues()
    
        
    /********************************* Spawn Timers *********************************/
    // MARK: - Spawn Timers
        
        // Spawning bullets timer call
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(GameScene.spawnBullets), userInfo: nil, repeats: false)
        
        // Spawning wingmen timer call
        wingTimer = NSTimer.scheduledTimerWithTimeInterval(8.0, target: self, selector: #selector(GameScene.spawnWingman), userInfo: nil, repeats: true)

        // Spawning wingmen timer call
        wingTimer = NSTimer.scheduledTimerWithTimeInterval(12.0, target: self, selector: #selector(GameScene.spawnBomber), userInfo: nil, repeats: true)
        
        // Spawning enemies timer call
        enemyTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(GameScene.spawnEnemyPlane), userInfo: nil, repeats: true)

        // Spawning enemy fire timer call
        enemyShoots = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(GameScene.spawnEnemyFire), userInfo: nil, repeats: true)

        // Set enemy tank spawn intervals
        enemyTankTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(GameScene.spawnTank), userInfo: nil, repeats: true)
        
        // Spawning tank missile timer call
        enemyTankShoots = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(GameScene.spawnTankMissiles), userInfo: nil, repeats: true)
        
        // Cloud sound timer will for 12 sec and stop, then run again
        cloudTimer = NSTimer.scheduledTimerWithTimeInterval(24.0, target: self, selector: #selector(GameScene.rainBadCloud), userInfo: nil, repeats: true)
        
        // Spawning enemy fire timer call
        starTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(GameScene.spawnStar), userInfo: nil, repeats: true)
        
        
    /********************************* Preloading Sound & Music *********************************/
    // MARK: - Spawning
        
        // After import AVFoundation, needs do,catch statement to preload sound so no delay
        do {
            let sounds = ["Coin", "StartGame", "bgMusic", "biplaneFlying", "gunfire", "star", "thunder", "crash", "bomb", "bombDrop", "planesFight", "planeMachineGun", "bGCannons", "tank", "tankFiring", "airplaneFlyBy", "airplanep51"]
            
            for sound in sounds {
                let player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(sound, ofType: "mp3")!))
                player.prepareToPlay()
            }
        } catch {
            print("AVAudio has had an \(error).")
        }
        
        // Adds background sound to game
        bgMusic = SKAudioNode(fileNamed: "bgMusic")
        bgMusic.runAction(SKAction.play())
        bgMusic.autoplayLooped = true
        
        biplaneFlyingSound = SKAudioNode(fileNamed: "biplaneFlying")
        biplaneFlyingSound.runAction(SKAction.play())
        biplaneFlyingSound.autoplayLooped = true
        
        self.addChild(bgMusic)
        self.addChild(biplaneFlyingSound)
    }
    
    
    /********************************** Simulating Physics ***************************************/
    // MARK: - Simulate Physics
    
    override func didSimulatePhysics() {
        
    }
    
    
    /*********************************** Update Function *****************************************/
    // MARK: - Update Function
    
    // HUD for health meter
    override func update(currentTime: NSTimeInterval) {
        // Healthbar GUI
        playerHealthBar.position = CGPoint(x: myPlane.position.x, y: myPlane.position.y - myPlane.size.height / 2 - 15)
        updateHealthBar(playerHealthBar, withHealthPoints: playerHP)
        
        
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
    
    
    /********************************* touchesBegan Function **************************************/
    // MARK: - touchesBegan
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        touchLocation = touches.first!.locationInNode(self)
        
        for touch: AnyObject in touches {
            let location = (touch as! UITouch).locationInNode(self)
            
            /* Allows to tap on screen and plane will present
             at that axis and shoot at point touched */
            myPlane.position.y = location.y // Allows a tap to touch on the y axis
            myPlane.position.x = location.x // Allows a tap to touch on the x axis
            
            // Introduces the pause feature
            let node = self.nodeAtPoint(location)
            if (node.name == "PauseButton") || (node.name == "PauseButtonContainer") {
                showPauseAlert()
            }
            
            addGunfireToPlane()
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
            
            // Starting and stopping background sound
//            bgMusic.runAction(SKAction.pause())
        }
    }
    
    
    /********************************* touchesMoved Function **************************************/
    // MARK: - touchesMoved
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
        
        for touch: AnyObject in touches {
            let location = (touch as! UITouch).locationInNode(self)
            
            /* Allows to drag on screen and plane will follow
            that axis and shoot at point when released */
            myPlane.position.y = location.y // Allows a tap to touch on the y axis
            myPlane.position.x = location.x
            
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
    }
    
    
    /********************************* touchesEnded Function **************************************/
    // MARK: - touchesEnded
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Each node will collide with the equalled item due to bit mask
        
        // Spawning bullets for our player
        bullets.hidden = false
        spawnBullets()
        
        // Add sound to firing
        gunfireSound = SKAudioNode(fileNamed: "gunfire")
        gunfireSound.runAction(SKAction.play())
        gunfireSound.autoplayLooped = false
        
        self.addChild(gunfireSound)
        
        // Bullet physics
        bullets.physicsBody?.categoryBitMask = PhysicsCategory.MyBullets2
        bullets.physicsBody?.collisionBitMask = 2
        
        // Each node will collide with the equalled item due to bit mask
        bullets.physicsBody?.collisionBitMask =  PhysicsCategory.StarMask512 | PhysicsCategory.Enemy16
        
        // Which ones react to a collision
        bullets.physicsBody?.contactTestBitMask = bullets.physicsBody!.collisionBitMask | PhysicsCategory.StarMask512 | PhysicsCategory.Enemy16
        
        randomEnemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy16
        randomEnemy.physicsBody?.contactTestBitMask = PhysicsCategory.MyBullets2 | PhysicsCategory.Player8
        randomEnemy.physicsBody?.collisionBitMask = 16
    }
    // Want to use use a double tap or long press to drop bomb
    
    
    /************************************ didBeginContact *****************************************/
    // MARK: - didBeginContact
    
    func didBeginContact(contact: SKPhysicsContact) {
        print("PLANE HAS CONTACT")
        
        if !self.gamePaused {
            holdGame()
        }
        
        let bullet = (contact.bodyA.categoryBitMask == PhysicsCategory.MyBullets2) ? contact.bodyA: contact.bodyB
        let enemy = (bullet == contact.bodyA) ? contact.bodyB: contact.bodyA
        if enemy.categoryBitMask == PhysicsCategory.StarMask512 || enemy.categoryBitMask == PhysicsCategory.Enemy16 {
            self.didHitNode(enemy)
        }

        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB

        if ((firstBody.categoryBitMask == PhysicsCategory.Enemy16) && (secondBody.categoryBitMask == PhysicsCategory.MyBullets2) || (firstBody.categoryBitMask == PhysicsCategory.MyBullets2) && (secondBody.categoryBitMask == PhysicsCategory.Enemy16)) {
                self.didBulletsHitEnemy(firstBody.node as! SKSpriteNode, MyBullets: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Enemy16) && (secondBody.categoryBitMask == PhysicsCategory.Player8) || (firstBody.categoryBitMask == PhysicsCategory.Player8) && (secondBody.categoryBitMask == PhysicsCategory.Enemy16)) {
                self.didEnemyHitPlayer(firstBody.node as! SKSpriteNode, Player: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.EnemyFire64) && (secondBody.categoryBitMask == PhysicsCategory.Player8) || (firstBody.categoryBitMask == PhysicsCategory.Player8) && (secondBody.categoryBitMask == PhysicsCategory.EnemyFire64)) {
                self.didEnemyFireHitPlayer(firstBody.node as! SKSpriteNode, Player: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.MyBullets2) && (secondBody.categoryBitMask == PhysicsCategory.StarMask512) || (firstBody.categoryBitMask == PhysicsCategory.StarMask512) && (secondBody.categoryBitMask == PhysicsCategory.MyBullets2)) {
                self.didBulletsHitStar(firstBody.node as! SKSpriteNode, StarMask: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Player8) && (secondBody.categoryBitMask == PhysicsCategory.StarMask512) || (firstBody.categoryBitMask == PhysicsCategory.StarMask512) && (secondBody.categoryBitMask == PhysicsCategory.Player8)) {
                self.didPlayerHitStar(firstBody.node as! SKSpriteNode, StarMask: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.MyBullets2) && (secondBody.categoryBitMask == PhysicsCategory.Cloud256) || (firstBody.categoryBitMask == PhysicsCategory.Cloud256) && (secondBody.categoryBitMask == PhysicsCategory.MyBullets2)) {
                self.didBulletsHitCloud(firstBody.node as! SKSpriteNode, Cloud: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Player8) && (secondBody.categoryBitMask == PhysicsCategory.Ground1) || (firstBody.categoryBitMask == PhysicsCategory.Ground1) && (secondBody.categoryBitMask == PhysicsCategory.Player8)) {
                self.didPlayerHitGround(firstBody.node as! SKSpriteNode, Ground: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.MyBombs4) && (secondBody.categoryBitMask == PhysicsCategory.Ground1) || (firstBody.categoryBitMask == PhysicsCategory.Ground1) && (secondBody.categoryBitMask == PhysicsCategory.MyBombs4)) {
                self.didBombHitGround(firstBody.node as! SKSpriteNode, Ground: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.MyBombs4) && (secondBody.categoryBitMask == PhysicsCategory.Tank32) || (firstBody.categoryBitMask == PhysicsCategory.Tank32) && (secondBody.categoryBitMask == PhysicsCategory.MyBombs4)) {
            self.didBombHitTank(firstBody.node as! SKSpriteNode, Tank: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.MyBombs4) && (secondBody.categoryBitMask == PhysicsCategory.Enemy16) || (firstBody.categoryBitMask == PhysicsCategory.Enemy16) && (secondBody.categoryBitMask == PhysicsCategory.MyBombs4)) {
            self.didBombHitEnemy(firstBody.node as! SKSpriteNode, Enemy: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.MyBullets2) && (secondBody.categoryBitMask == PhysicsCategory.Coins1024) || (firstBody.categoryBitMask == PhysicsCategory.Coins1024) && (secondBody.categoryBitMask == PhysicsCategory.MyBullets2)) {
            self.didBulletsHitCoins(firstBody.node as! SKSpriteNode, Coins: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Player8) && (secondBody.categoryBitMask == PhysicsCategory.Coins1024) || (firstBody.categoryBitMask == PhysicsCategory.Coins1024) && (secondBody.categoryBitMask == PhysicsCategory.Player8)) {
            self.didPlayerHitCoins(firstBody.node as! SKSpriteNode, Coins: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Rain2048) && (secondBody.categoryBitMask == PhysicsCategory.Player8) || (firstBody.categoryBitMask == PhysicsCategory.Player8) && (secondBody.categoryBitMask == PhysicsCategory.Rain2048)) {
            self.didRainHitPlayer(firstBody.node as! SKSpriteNode, Player: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Rain2048) && (secondBody.categoryBitMask == PhysicsCategory.Enemy16) || (firstBody.categoryBitMask == PhysicsCategory.Enemy16) && (secondBody.categoryBitMask == PhysicsCategory.Rain2048)) {
            self.didRainHitEnemy(firstBody.node as! SKSpriteNode, Enemy: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Rain2048) && (secondBody.categoryBitMask == PhysicsCategory.Tank32) || (firstBody.categoryBitMask == PhysicsCategory.Tank32) && (secondBody.categoryBitMask == PhysicsCategory.Rain2048)) {
            self.didRainHitTank(firstBody.node as! SKSpriteNode, Tank: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Rain2048) && (secondBody.categoryBitMask == PhysicsCategory.EnemyFire64) || (firstBody.categoryBitMask == PhysicsCategory.EnemyFire64) && (secondBody.categoryBitMask == PhysicsCategory.Rain2048)) {
            self.didRainHitEnemyFire(firstBody.node as! SKSpriteNode, EnemyFire: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Rain2048) && (secondBody.categoryBitMask == PhysicsCategory.Missiles128) || (firstBody.categoryBitMask == PhysicsCategory.Missiles128) && (secondBody.categoryBitMask == PhysicsCategory.Rain2048)) {
            self.didRainHitMissiles(firstBody.node as! SKSpriteNode, Missiles: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Rain2048) && (secondBody.categoryBitMask == PhysicsCategory.StarMask512) || (firstBody.categoryBitMask == PhysicsCategory.StarMask512) && (secondBody.categoryBitMask == PhysicsCategory.Rain2048)) {
            self.didRainHitStar(firstBody.node as! SKSpriteNode, Stars: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Rain2048) && (secondBody.categoryBitMask == PhysicsCategory.Coins1024) || (firstBody.categoryBitMask == PhysicsCategory.Coins1024) && (secondBody.categoryBitMask == PhysicsCategory.Rain2048)) {
            self.didRainHitCoins(firstBody.node as! SKSpriteNode, Coins: secondBody.node as! SKSpriteNode)
        }
    }
    
    
    /***************************** Collision Functions *********************************/
    // MARK: - Collision Functions
    
    // Function created to give reaction to star colliding
    func didHitNode(enemy: SKPhysicsBody) {
        let fire: SKEmitterNode = SKEmitterNode(fileNamed: "FireExplosion")!
        let smoke: SKEmitterNode = SKEmitterNode(fileNamed: "Smoke")!
        fire.position = enemy.node!.position
        smoke.position = enemy.node!.position
        enemy.node?.removeFromParent()
        self.addChild(fire)
        self.addChild(smoke)
        
        // Adding sound to the star hits
        bombDropSound = SKAudioNode(fileNamed: "bombDrop")
        bombDropSound.runAction(SKAction.play())
        bombDropSound.autoplayLooped = false
        
        self.addChild(bombDropSound)
        
        score += 5
    }

    // Function if player hits enemy with weapon
    func didBulletsHitEnemy (Enemy: SKSpriteNode, MyBullets: SKSpriteNode) {
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
        
        // Hitting an object loses points off score
        score += 10
        health += 2
    }
    
    // Function if player hit enemy or enemy hits player
    func didEnemyHitPlayer (Enemy: SKSpriteNode, Player: SKSpriteNode) {
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        smoke = SKEmitterNode(fileNamed: "Smoke")
        
        explosion.position = Enemy.position
        smoke.position = Enemy.position
        
        Enemy.removeFromParent()
        Player.removeFromParent()
        self.addChild(explosion)
        self.addChild(smoke)
        
        crashSound = SKAudioNode(fileNamed: "crash")
        crashSound.runAction(SKAction.play())
        crashSound.autoplayLooped = false
        
        self.addChild(crashSound)
        
        health -= 5
        score -= 5
    }
    
    // Function if player hit enemy or enemy hits player
    func didEnemyFireHitPlayer (EnemyFire: SKSpriteNode, Player: SKSpriteNode) {
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        smoke = SKEmitterNode(fileNamed: "Smoke")
        
        explosion.position = Player.position
        smoke.position = Player.position
        
        EnemyFire.removeFromParent()
        Player.removeFromParent()
        smokeTrail.removeFromParent()
        gunfire.removeFromParent()
        self.addChild(explosion)
        self.addChild(smoke)
        
        crashSound = SKAudioNode(fileNamed: "crash")
        crashSound.runAction(SKAction.play())
        crashSound.autoplayLooped = false
        
        self.addChild(crashSound)
        
        health -= 5
    }
    
    // Function if player hits star with bullets
    func didBulletsHitStar(MyBullets: SKSpriteNode, StarMask: SKSpriteNode) {
        // The star will emit a spark and sound when hit
        explode = SKEmitterNode(fileNamed: "Explode")
        explode.position = StarMask.position
        
        // Adds star to make sound
        StarMask.removeFromParent()
        MyBullets.removeFromParent()
        self.addChild(explode)
        
        // Calling pre-loaded sound to the star hits
        starSound = SKAudioNode(fileNamed: "star")
        starSound.runAction(SKAction.play())
        starSound.autoplayLooped = false
        
        self.addChild(starSound)
        
        // Points per star added to score
        score += 2
        health += 1
    }
    
    // Function if player hits star
    func didPlayerHitStar(Player: SKSpriteNode, StarMask: SKSpriteNode) {
        // The star will emit a spark and sound when hit
        explode = SKEmitterNode(fileNamed: "Explode")
        explode.position = StarMask.position
        
        self.addChild(explode)
        
        // Adds star to make sound
        StarMask.removeFromParent()
        
        // Calling pre-loaded sound to the star hits
        starSound = SKAudioNode(fileNamed: "star")
        starSound.runAction(SKAction.play())
        starSound.autoplayLooped = false
        
        self.addChild(starSound)
        
        // Points per star added to score
        score += 1
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
        
        thunderSound = SKAudioNode(fileNamed: "thunder")
        thunderSound.runAction(SKAction.play())
        thunderSound.autoplayLooped = false
        
        self.addChild(thunderSound)
        
        health -= 1
    }
    
    // Function if bomb hits the ground
    func didBombHitGround(MyBomb: SKSpriteNode, Ground: SKSpriteNode) {
        /* Enemy (including ground or obstacle) will
         emit explosion, smoke and sound when hit*/
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        explosion.position = MyBomb.position
        
        self.addChild(explosion)
        
        MyBomb.removeFromParent()
        
        bombDropSound = SKAudioNode(fileNamed: "bombDrop")
        bombDropSound.runAction(SKAction.play())
        bombDropSound.autoplayLooped = false
        
        self.addChild(bombDropSound)
    }

    // Function if player hits star with bullets
    func didBulletsHitCoins(MyBullets: SKSpriteNode, Coins: SKSpriteNode) {
        // The star will emit a spark and sound when hit
        explode = SKEmitterNode(fileNamed: "Explode")
        explode.position = Coins.position
        
        self.addChild(explode)
        
        // Adds star to make sound
        Coins.removeFromParent()
        MyBullets.removeFromParent()
        
        // Calling pre-loaded sound to the star hits
        coinSound = SKAudioNode(fileNamed: "Coin")
        coinSound.runAction(SKAction.play())
        coinSound.autoplayLooped = false
        
        self.addChild(coinSound)
        
        // Points per star added to score
        score += 2
        health += 1
    }
    
    // Function if player hits star
    func didPlayerHitCoins(Player: SKSpriteNode, Coins: SKSpriteNode) {
        // The star will emit a spark and sound when hit
        explode = SKEmitterNode(fileNamed: "Explode")
        explode.position = Coins.position
        
        self.addChild(explode)
        
        // Adds star to make sound
        Coins.removeFromParent()
        
        // Calling pre-loaded sound to the star hits
        coinSound = SKAudioNode(fileNamed: "Coin")
        coinSound.runAction(SKAction.play())
        coinSound.autoplayLooped = false
        
        self.addChild(coinSound)
        
        // Points per star added to score
        score += 5
        health += 1
    }
    
    // Function if player hits the ground
    func didPlayerHitGround(Player: SKSpriteNode, Ground: SKSpriteNode) {
        /* Enemy (including ground or obstacle) will 
        emit explosion, smoke and sound when hit*/
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        smoke = SKEmitterNode(fileNamed: "Smoke")
        
        explosion.position = Player.position
        smoke.position = Player.position
        
        self.addChild(explosion)
        self.addChild(smoke)
        
        Player.removeFromParent()
        gunfire.removeFromParent()
        
        crashSound = SKAudioNode(fileNamed: "crash")
        crashSound.runAction(SKAction.play())
        crashSound.autoplayLooped = false
        
        self.addChild(crashSound)
    }
    
    // Function if bomb hits the tank
    func didBombHitTank(Bomb: SKSpriteNode, Tank: SKSpriteNode) {
        /* Enemy (including ground or obstacle) will
         emit explosion, smoke and sound when hit*/
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        smoke = SKEmitterNode(fileNamed: "Smoke")
        
        explosion.position = Tank.position
        smoke.position = Tank.position
        
        self.addChild(explosion)
        self.addChild(smoke)
        
        Tank.removeFromParent()
        Bomb.removeFromParent()
        
        bombDropSound = SKAudioNode(fileNamed: "bombDrop")
        bombDropSound.runAction(SKAction.play())
        bombDropSound.autoplayLooped = false
        
        self.addChild(bombDropSound)
        
        score += 10
        health += 2
    }
    
    // Function if bomb hits the tank
    func didBombHitEnemy(Bomb: SKSpriteNode, Enemy: SKSpriteNode) {
        /* Enemy (including ground or obstacle) will
         emit explosion, smoke and sound when hit*/
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        smoke = SKEmitterNode(fileNamed: "Smoke")
        
        explosion.position = Enemy.position
        smoke.position = Enemy.position
        
        self.addChild(explosion)
        self.addChild(smoke)
        
        Enemy.removeFromParent()
        Bomb.removeFromParent()
        
        crashSound = SKAudioNode(fileNamed: "crash")
        crashSound.runAction(SKAction.play())
        crashSound.autoplayLooped = false
        
        self.addChild(crashSound)
        
        score += 12
        health += 2
    }

    // Function if Rain hits player
    func didRainHitPlayer (Rain: SKSpriteNode, Player: SKSpriteNode) {
        smoke = SKEmitterNode(fileNamed: "Smoke")
        smoke.position = Player.position
        self.addChild(smoke)
    }
    
    // Function if rain hits enemy plane
    func didRainHitEnemy (Rain: SKSpriteNode, Enemy: SKSpriteNode) {
        smoke = SKEmitterNode(fileNamed: "Smoke")
        smoke.position = Enemy.position
        self.addChild(smoke)
    }
    
    // Function if rain hits tank
    func didRainHitTank (Rain: SKSpriteNode, Tank: SKSpriteNode) {
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        smoke = SKEmitterNode(fileNamed: "Smoke")
        
        self.addChild(explosion)
        self.addChild(smoke)
        
        explosion.position = Tank.position
        smoke.position = Tank.position
        
        Tank.removeFromParent()
        
        crashSound = SKAudioNode(fileNamed: "crash")
        crashSound.runAction(SKAction.play())
        crashSound.autoplayLooped = false
        
        self.addChild(crashSound)
    }
    
    // Function if rain hits enemyfire
    func didRainHitEnemyFire (Rain: SKSpriteNode, EnemyFire: SKSpriteNode) {
        explode = SKEmitterNode(fileNamed: "Explode")
        explode.position = EnemyFire.position

        self.addChild(explode)
        
        EnemyFire.removeFromParent()
        
        planeMGunSound = SKAudioNode(fileNamed: "planeMachineGun")
        planeMGunSound.runAction(SKAction.play())
        planeMGunSound.autoplayLooped = false
        
        self.addChild(planeMGunSound)
    }
    
    // Function if rain hits missiles
    func didRainHitMissiles (Rain: SKSpriteNode, Missiles: SKSpriteNode) {
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        smoke = SKEmitterNode(fileNamed: "Smoke")
        
        self.addChild(explosion)
        self.addChild(smoke)
        
        explosion.position = Missiles.position
        smoke.position = Missiles.position
        
        missiles.removeFromParent()
        
        bombDropSound = SKAudioNode(fileNamed: "bombDrop")
        bombDropSound.runAction(SKAction.play())
        bombDropSound.autoplayLooped = false
        
        self.addChild(bombDropSound)
    }
    
    // Function if rain hits stars
    func didRainHitStar (Rain: SKSpriteNode, Stars: SKSpriteNode) {
        explode = SKEmitterNode(fileNamed: "Explode")
        explode.position = Stars.position
        
        Stars.removeFromParent()
        
        starSound = SKAudioNode(fileNamed: "star")
        starSound.runAction(SKAction.play())
        starSound.autoplayLooped = false
        
        self.addChild(explode)
        
        self.addChild(starSound)
    }
    
    // Function if rain hits coins
    func didRainHitCoins (Rain: SKSpriteNode, Coins: SKSpriteNode) {
        explode = SKEmitterNode(fileNamed: "Explode")
        explode.position = Coins.position
        
        Coins.removeFromParent()
        
        coinSound = SKAudioNode(fileNamed: "Coin")
        coinSound.runAction(SKAction.play())
        coinSound.autoplayLooped = false
        
        self.addChild(explode)
        
        self.addChild(coinSound)
    }
    
    /*************************************** Pause ******************************************/
    
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
        let display = SKSpriteNode(color: UIColor.blackColor(), size: CGSizeMake(self.size.width, self.size.height * 0.05))
        display.anchorPoint = CGPointMake(0, 0)
        display.position = CGPointMake(0, self.size.height - display.size.height)
        self.addChild(display)
        
        // Pause button container and label
        let pauseNode = SKSpriteNode()
        pauseNode.position = CGPointMake(display.size.width / 1.5, 1)
        pauseNode.size = CGSizeMake(display.size.height * 3, display.size.height * 2)
        pauseNode.name = "PauseButtonContainer"
        display.addChild(pauseNode)
        
        var pauseButton = SKLabelNode()
        pauseButton = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        pauseButton.position = CGPointMake(display.size.width / 1.5, 1)
        pauseButton.text = "PAUSE"
        pauseButton.fontSize = display.size.height
        pauseButton.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        pauseButton.name = "PauseButton"
        display.addChild(pauseButton)
    }
    
    func holdGame() {
        
        self.gamePaused = true
        
        // Stop movement, fade out, move to center, fade in
        myPlane.removeAllActions()
        self.myPlane.runAction(SKAction.fadeOutWithDuration(1) , completion: {
            self.myPlane.position = CGPointMake(self.size.width/2, self.size.height/2)
            self.myPlane.runAction(SKAction.fadeInWithDuration(1), completion: {
                self.gamePaused = false
            })
        })
    }

    /********************************* Background Functions *********************************/
    // MARK: - Background Functions
    
    // Adding scrolling background
    func createBackground() {
        let myBackground = SKTexture(imageNamed: "cartoonCloudsBGLS")
        
        for i in 0...1 {
            let background = SKSpriteNode(texture: myBackground)
            background.zPosition = -30
            background.anchorPoint = CGPointZero
            background.position = CGPoint(x: (myBackground.size().width * CGFloat(i)) - CGFloat(1 * i), y: 0)
            addChild(background)
            
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
            ground.zPosition = -20
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
            ground.zPosition = -10
            ground.position = CGPoint(x: (foreground.size().width / 2.0 + (foreground.size().width * CGFloat(i))), y: foreground.size().height / 2)
            
            // Create physics body
            ground.physicsBody?.affectedByGravity = false
            
            addChild(ground)
            
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
        myPlane.setScale(0.15)
        myPlane.zPosition = -5
        myPlane.position = CGPoint(x: self.size.width / 6, y: self.size.height / 2)
        
        // Body physics of player's plane
        myPlane.physicsBody = SKPhysicsBody(rectangleOfSize: myPlane.size)
        myPlane.physicsBody?.affectedByGravity = false
        myPlane.physicsBody?.categoryBitMask = PhysicsCategory.Player8
        myPlane.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy16 | PhysicsCategory.Ground1 | PhysicsCategory.EnemyFire64
        myPlane.physicsBody?.collisionBitMask = 8
        myPlane.physicsBody?.dynamic = false
        
        myPlane.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(planeArray, timePerFrame: 0.05)))
        
        self.addChild(myPlane)        
    }
    
    
    /*********************************** Spawning Functions *********************************/
    // MARK: - Spawning Functions
    
    // Spawn bullets for player's plane
    func spawnBullets() {
        
        // Setup bullet node
        bullets = SKSpriteNode(imageNamed: "fireBullet")
        bullets.zPosition = -5
        
        bullets.position = CGPoint(x: myPlane.position.x + 50, y: myPlane.position.y)
        
        // Body physics of player's bullets
        bullets.physicsBody = SKPhysicsBody(rectangleOfSize: bullets.size)
        bullets.physicsBody?.affectedByGravity = false
        bullets.physicsBody?.categoryBitMask = PhysicsCategory.MyBullets2
        bullets.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy16 | PhysicsCategory.StarMask512 | PhysicsCategory.Cloud256 | PhysicsCategory.Coins1024
        bullets.physicsBody?.collisionBitMask = 2
        bullets.physicsBody?.usesPreciseCollisionDetection = true
        bullets.physicsBody?.dynamic = false
        
        // Shoot em up!
        let action = SKAction.moveToX(self.size.width + 100, duration: 0.75)
        let actionDone = SKAction.removeFromParent()
        bullets.runAction(SKAction.sequence([action, actionDone]))
        
        self.addChild(bullets)
    }
    
    // Spawning bombs for player's plane
    func spawnBombs() {

        // Setup bomb node
        bombs = SKSpriteNode(imageNamed: "bomb1")
//        bombs.setScale(0.2)
        bombs.zPosition = 5
        
        bombs.position = CGPointMake(myPlane.position.x, myPlane.position.y)
        
        // Body physics of player's bullets
        bombs.physicsBody = SKPhysicsBody(rectangleOfSize: bombs.size)
        bombs.physicsBody?.affectedByGravity = false
        bombs.physicsBody?.categoryBitMask = PhysicsCategory.MyBombs4
        bombs.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy16 | PhysicsCategory.StarMask512 | PhysicsCategory.Cloud256 | PhysicsCategory.Ground1
        bombs.physicsBody?.collisionBitMask = 4
        bombs.physicsBody?.usesPreciseCollisionDetection = true
        bombs.physicsBody?.dynamic = false
        
        // Drop em!
        let action = SKAction.moveToY(-80, duration: 2.0)
        let actionDone = SKAction.removeFromParent()
        bombs.runAction(SKAction.sequence([action, actionDone]))
        
        self.addChild(bombs)
        
        // Adding sound
        bombSound = SKAudioNode(fileNamed: "bomb")
        bombSound.runAction(SKAction.play())
        bombSound.autoplayLooped = false
        
//        self.addChild(bombSound)
        
        bombs.hidden = true
    }

    // Adding ally forces in background
    func spawnWingman() {
        
        // Alternate wingmen 1 of 2 passby's in the distance
        wingman = SKSpriteNode(imageNamed: "wingman")
        wingman.zPosition = -19
        wingman.setScale(0.5)
        
        // Calculate random spawn points for wingmen
        let random = CGFloat(arc4random_uniform(1000) + 400)
        wingman.position = CGPoint(x: -self.size.width, y: random)
        
        // Body physics for player's wingmen
        wingman.physicsBody = SKPhysicsBody(rectangleOfSize: wingman.size)
        wingman.physicsBody?.affectedByGravity = false
        wingman.physicsBody?.dynamic = false
        
        // Move wingmen forward
        let action = SKAction.moveToX(self.size.width + 50, duration: 18.0)
        let actionDone = SKAction.removeFromParent()
        wingman.runAction(SKAction.sequence([action, actionDone]))
        
        wingman.removeFromParent()
        self.addChild(wingman) // Generate the random wingman
    }
    
    // Adding ally forces in background
    func spawnBomber() {
        
        // Alternate wingmen 2 of 2 passby's in the distance
        bomber = SKSpriteNode(imageNamed: "bomber")
        bomber.zPosition = -19
        bomber.setScale(0.4)
        
        // Calculate random spawn points for bomber
        let random = CGFloat(arc4random_uniform(1000) + 400)
        bomber.position = CGPoint(x: -self.size.width, y: random)
        
        // Body physics for player's bomber
        bomber.physicsBody = SKPhysicsBody(rectangleOfSize: bomber.size)
        bomber.physicsBody?.affectedByGravity = false
        bomber.physicsBody?.dynamic = false
        
        // Move bomber forward
        let action = SKAction.moveToX(self.size.width + 80, duration: 22.0)
        let actionDone = SKAction.removeFromParent()
        bomber.runAction(SKAction.sequence([action, actionDone]))
        
        bomber.removeFromParent()
        self.addChild(bomber) // Generate the random wingman
    }
    
    // Generate enemy fighter planes
    func spawnEnemyPlane() {
        
        // Sky enemy array
        enemyArray = [enemy1, enemy2, enemy3, enemy4]
        
        // Generate a random index
        let randomIndex = Int(arc4random_uniform(UInt32(enemyArray.count)))
        
        // Get a random enemy
        randomEnemy = enemyArray[randomIndex]

        randomEnemy.setScale(0.25)
        randomEnemy.zPosition = -5
        
        // Calculate random spawn points for air enemies
        randomEnemy.position = CGPoint(x: self.size.width, y: CGFloat(arc4random_uniform(800) + 250))
        
        // Body physics for enemy's planes
        randomEnemy.physicsBody = SKPhysicsBody(rectangleOfSize: randomEnemy.size)
        randomEnemy.physicsBody?.affectedByGravity = false
        randomEnemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy16
        randomEnemy.physicsBody?.contactTestBitMask = PhysicsCategory.Player8 | PhysicsCategory.MyBullets2 | PhysicsCategory.Enemy16 | PhysicsCategory.EnemyFire64
        randomEnemy.physicsBody?.collisionBitMask = 16
        randomEnemy.physicsBody?.dynamic = false

        // Move enemies forward
        let action = SKAction.moveToX(-200, duration: 4.0)
        let actionDone = SKAction.removeFromParent()
        randomEnemy.runAction(SKAction.sequence([action, actionDone]))
        
        enemy1.removeFromParent()
        enemy2.removeFromParent()
        enemy3.removeFromParent()
        enemy4.removeFromParent()
        randomEnemy.removeFromParent()
        self.addChild(randomEnemy) // Generate the random enemy
        
        // Add sound
        airplaneFlyBySound = SKAudioNode(fileNamed: "airplaneFlyBy")
        airplaneFlyBySound.runAction(SKAction.play())
        airplaneFlyBySound.autoplayLooped = false
        
        airplaneP51Sound = SKAudioNode(fileNamed: "airplanep51")
        airplaneP51Sound.runAction(SKAction.play())
        airplaneP51Sound.autoplayLooped = false
        
        self.addChild(airplaneP51Sound)
        self.addChild(airplaneFlyBySound)

        spawnEnemyFire()
    }

    func spawnEnemyFire() {
        enemyFire = SKSpriteNode(imageNamed: "enemyFire")
        enemyFire.setScale(0.2)
        enemyFire.zPosition = -5

        enemyFire.position = CGPointMake(randomEnemy.position.x - 75, randomEnemy.position.y)

        // Body physics of player's bullets
        enemyFire.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        enemyFire.physicsBody?.affectedByGravity = false
        enemyFire.physicsBody?.categoryBitMask = PhysicsCategory.EnemyFire64
        enemyFire.physicsBody?.contactTestBitMask = PhysicsCategory.Player8 | PhysicsCategory.Enemy16 | PhysicsCategory.MyBullets2
        enemyFire.physicsBody?.collisionBitMask = 64
        enemyFire.physicsBody?.dynamic = false

        // Shoot em up!
        let action = SKAction.moveToX(-30, duration: 1.0)
        let actionDone = SKAction.removeFromParent()
        enemyFire.runAction(SKAction.sequence([action, actionDone]))
        
        self.addChild(enemyFire) // Generate enemy fire
        
        // Add sound
        planeMGunSound = SKAudioNode(fileNamed: "planeMachineGun")
        planeMGunSound.runAction(SKAction.play())
        planeMGunSound.autoplayLooped = false
        
//        self.addChild(planeMGunSound)
    }
    
    // Spawn ground tank - it can't fly!! ;)
    func spawnTank() {
        
        // Spawning an enemy tank
        tank = SKSpriteNode(imageNamed: "tank")
        tank.setScale(0.2)
        tank.zPosition = 2

        tank.position = CGPoint(x: self.size.width, y: self.size.height + 150)
        
        // Added tank physics
        tank.physicsBody = SKPhysicsBody(rectangleOfSize: tank.size)
        tank.physicsBody?.affectedByGravity = false
        tank.physicsBody?.categoryBitMask = PhysicsCategory.Tank32
        tank.physicsBody?.contactTestBitMask = PhysicsCategory.Player8 | PhysicsCategory.MyBullets2 | PhysicsCategory.Enemy16 | PhysicsCategory.EnemyFire64
        tank.physicsBody?.collisionBitMask = 32
        tank.physicsBody?.dynamic = true
        
        // Shoot em up!
        let action = SKAction.moveToX(-200, duration: 8.0)
        let actionDone = SKAction.removeFromParent()
        tank.runAction(SKAction.sequence([action, actionDone]))
        
        self.addChild(tank) // Generate enemy tank
        
        // Add sound
        tankSound = SKAudioNode(fileNamed: "tank")
        tankSound.runAction(SKAction.play())
        tankSound.autoplayLooped = false
        
        self.addChild(tankSound)
    }
    
    // Spawn enemy tank missiles
    func spawnTankMissiles() {
        
        // Spawning an enemy tank's anti-aircraft missiles
        missiles = SKSpriteNode(imageNamed: "missile")
        missiles.setScale(0.5)
        missiles.zPosition = -9
        
        missiles.position = CGPoint(x: tank.position.x, y: tank.position.y)
        
        // Added missile physics
        missiles.physicsBody = SKPhysicsBody(rectangleOfSize: missiles.size)
        missiles.physicsBody?.affectedByGravity = false
        missiles.physicsBody?.categoryBitMask = PhysicsCategory.Missiles128
        missiles.physicsBody?.contactTestBitMask = PhysicsCategory.Player8 | PhysicsCategory.MyBullets2
        missiles.physicsBody?.collisionBitMask = 128
        missiles.physicsBody?.dynamic = false

        // Shoot em up!
        let action = SKAction.moveToY(self.size.height + 80, duration: 3.0)
        let actionDone = SKAction.removeFromParent()
        missiles.runAction(SKAction.sequence([action, actionDone]))
        
        self.addChild(missiles) // Generate tank missile
        
        // Add sound
        tankFiringSound = SKAudioNode(fileNamed: "tankFiring")
        tankFiringSound.runAction(SKAction.play())
        tankFiringSound.autoplayLooped = false
        
//        self.addChild(tankFiringSound)
    }
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    // Introducing the cloud using linear interpolation
    func cloudOnAPath() {
        
        badCloud = SKSpriteNode(imageNamed: "badCloud")
        badCloud.zPosition = -21
        
        // Randomly place cloud on Y axis
        let actualY = random(min: badCloud.size.height / 2, max: size.height - badCloud.size.height / 2 + 400)
        
        // Clouds position off screen
        badCloud.position = CGPoint(x: size.width + badCloud.size.width / 2, y: actualY)
        
        // This time I will determine speed by velocity rather than time interval
        let actualDuration = random(min: CGFloat(10.0), max: CGFloat(15.0))
        
        // Added star's physics
        badCloud.physicsBody = SKPhysicsBody(edgeLoopFromRect: badCloud.frame)
        badCloud.physicsBody?.affectedByGravity = false
        badCloud.physicsBody?.categoryBitMask = PhysicsCategory.Cloud256
        badCloud.physicsBody?.contactTestBitMask = PhysicsCategory.Player8 | PhysicsCategory.MyBullets2
        badCloud.physicsBody?.collisionBitMask = 256
        badCloud.physicsBody?.dynamic = false
        
        self.addChild(badCloud) // Generate "bonus" star
        
        // Create a path func cloudOnAPath() {
        let actionMove = SKAction.moveTo(CGPoint(x: -badCloud.size.width / 2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        badCloud.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        badCloud.shadowCastBitMask = 1
        badCloud.lightingBitMask = 1
    }
    
    // Spawning a bonus star
    func spawnStar() {
        
        // Randomly place stars on Y axis
        let actualY = random(min: star.size.height / 2 + 100, max: size.height - star.size.height / 4 + 200)
        let actualX = random(min: star.size.width / 2, max: size.width - star.size.width / 3 + 50)
        
        // Star position off screen
        star.position = CGPoint(x: actualX, y: actualY)
        star.setScale(3.0)
        
        // Added star's physics
        star.physicsBody = SKPhysicsBody(edgeLoopFromRect: star.frame)
        star.physicsBody?.affectedByGravity = false
        star.physicsBody?.categoryBitMask = PhysicsCategory.StarMask512
        star.physicsBody?.contactTestBitMask = PhysicsCategory.Player8 | PhysicsCategory.MyBullets2 | PhysicsCategory.MyBombs4 | PhysicsCategory.Enemy16 | PhysicsCategory.EnemyFire64 | PhysicsCategory.Missiles128
        star.physicsBody?.collisionBitMask = 512
        star.physicsBody?.dynamic = false
        
        // Since the star texture is only one frame, we can set it here:
        star = SKSpriteNode(imageNamed: "star")
        star.runAction(pulseAnimation)
        
        self.addChild(star)
        
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
    

    /*********************************** Emitter Functions *********************************/
    // MARK: - Emitter Functions
    
    // Adding emitter to follow cloud and rain in time intervals
    func rainBadCloud() {
        
        // Cloud will rain within intervals
        rain = SKEmitterNode(fileNamed: "Rain")
        rain.zPosition = -29
        rain.setScale(0.8)
        
        // Set physics for rain
        rain.physicsBody?.affectedByGravity = false
        rain.physicsBody?.categoryBitMask = PhysicsCategory.Rain2048
        rain.physicsBody?.contactTestBitMask = PhysicsCategory.Player8 | PhysicsCategory.Enemy16 | PhysicsCategory.Tank32 | PhysicsCategory.EnemyFire64 | PhysicsCategory.Missiles128 | PhysicsCategory.StarMask512 | PhysicsCategory.Coins1024
        rain.physicsBody?.collisionBitMask = 2048
        
        // Follows cloud
        rain.targetNode = self.scene
        badCloud.addChild(rain)
        
        thunderSound = SKAudioNode(fileNamed: "thunder")
        
        thunderSound.runAction(SKAction.play())
        thunderSound.autoplayLooped = false
        
        self.addChild(thunderSound)
    }
    
    // Add emitter of fire when bullets are fired
    func addGunfireToPlane() {
        
        // The plane will emit gunfire effect
        gunfire = SKEmitterNode(fileNamed: "Gunfire")
        gunfire.particleZPosition = 1
        gunfire.particleScale = 0.6
        
        // Stays with plane
        gunfire.targetNode = self.scene
        myPlane.addChild(gunfire)
    }
    
    // Add emitter of fire when bullets are fired
    func addGunfireToPlane2() {
        
        // The plane will emit gunfire effect
        gunfire = SKEmitterNode(fileNamed: "Gunfire")
        gunfire.particleZPosition = 1
        gunfire.particleScale = 0.6
        
        // Influenced by plane's movement
        gunfire.targetNode = self.scene
        randomEnemy.addChild(gunfire)
        
        // Add sounds to enemy planes
        planesFightSound = SKAudioNode(fileNamed: "planesFight")
        planesFightSound.runAction(SKAction.play())
        planesFightSound.autoplayLooped = false
        
//        self.addChild(planesFightSound)
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
    
    // Healthbar function for visual display
    func updateHealthBar(node: SKSpriteNode, withHealthPoints hp: Int) {
        
        let barSize = CGSize(width: healthBarWidth, height: healthBarHeight);
        
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
    }
    
    //INITIALIZATION VALUES - GOES NEAR BOTTOM AFTER LAST OBJECT SPAWNED
    //Sets the initial values for our variables
    func initializeValues(){
//        self.removeAllChildren()
        
        score = 0
        gameOver = false
        currentNumberOfEnemies = 0
        timeBetweenEnemies = 1.0
        health = 20
        nextTime = NSDate()
        now = NSDate()
        
        healthLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        healthLabel.text = "Health: \(health)"
        healthLabel.fontSize = 40
        healthLabel.fontColor = SKColor.blackColor()
        healthLabel.position = CGPoint(x: frame.minX + 200, y: frame.minY + 50)
        
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.position = CGPoint(x: frame.maxX - 100, y: frame.maxY - 30)
        scoreLabel.horizontalAlignmentMode = .Right
        
        gameOverLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        gameOverLabel!.text = "GAME OVER"
        gameOverLabel!.fontSize = 80
        gameOverLabel!.fontColor = SKColor.blackColor()
        gameOverLabel!.position = CGPoint(x: CGRectGetMinX(self.frame)/2, y: (CGRectGetMinY(self.frame)/2))
        
        self.addChild(healthLabel)
        self.addChild(scoreLabel)
//        self.addChild(gameOverLabel!)
    }
}
