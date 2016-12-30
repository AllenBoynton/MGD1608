//
//  GameScene.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/3/16.
//  Copyright (c) 2016 Full Sail. All rights reserved.
//

import SpriteKit
import AVFoundation


// Binary connections for collision and colliding
struct PhysicsCategory {
    static let None       : UInt32 = 0   // 0
    static let Ground1    : UInt32 = 1   // 0x1 << 0
    static let MyBullets2 : UInt32 = 2   // 0x1 << 1
    static let MyPlane4   : UInt32 = 4   // 0x1 << 2
    static let Enemy8     : UInt32 = 8   // 0x1 << 3
    static let EnemyFire16: UInt32 = 16  // 0x1 << 4
    static let Cloud32    : UInt32 = 32  // 0x1 << 5
    static let PowerUp64  : UInt32 = 64  // 0x1 << 6
    static let Coins128   : UInt32 = 128 // 0x1 << 7
    static let Rain256    : UInt32 = 256 // 0x1 << 8
    static let SkyBombs512: UInt32 = 512 // 0x1 << 9
    static let All        : UInt32 = UInt32.max // all nodes
}
    
// Global emitter objects
var gunfire = SKEmitterNode(fileNamed: "Gunfire")!
var smoke = SKEmitterNode(fileNamed: "Smoke")!
var explode = SKEmitterNode(fileNamed: "Explode")!
var explosion = SKEmitterNode(fileNamed: "FireExplosion")!
var rain = SKEmitterNode(fileNamed: "Rain")

// Global sound
// Audio nodes for sound effects and music
var audioPlayer = AVAudioPlayer()
var intro = SKAudioNode()
var bgMusic = SKAudioNode()
var startGameSound = SKAudioNode()
var biplaneFlyingSound = SKAudioNode()
var gunfireSound = SKAudioNode()
var coinSound = SKAudioNode()
var powerUpSound = SKAudioNode()
var skyBoomSound = SKAudioNode()
var crashSound = SKAudioNode()
var propSound = SKAudioNode()
var planesFightSound = SKAudioNode()
var bGCannonsSound = SKAudioNode()
var planeMGunSound = SKAudioNode()
var mortarSound = SKAudioNode()
var airplaneFlyBySound = SKAudioNode()
var airplaneP51Sound = SKAudioNode()
var mp5GunSound = SKAudioNode()

// HUD global variables
let maxHealth = 100
let healthBarWidth: CGFloat = 175
let healthBarHeight: CGFloat = 10
let playerHealthBar = SKSpriteNode()

let darkenOpacity: CGFloat = 0.5
let darkenDuration: CFTimeInterval = 2


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Location for touch screen
    var touchLocation = CGPoint.zero
    
    // Main background
    var myBackground = SKSpriteNode()
    
    // Mid background
    var midground = SKSpriteNode()
    
    // Foreground
    var foreground = SKSpriteNode()
    
    // MyPlane animation setup
    var node = SKNode()
    var myPlane = SKSpriteNode()
    var planeArray = [SKTexture]()
    
    // Image atlas's for animation
    var animation = SKAction()
    var animationFrames = [SKTexture]()
    var airplanesAtlas: SKTextureAtlas = SKTextureAtlas(named: "Airplanes")
    var assetsAtlas: SKTextureAtlas = SKTextureAtlas(named: "Assets")
    
    // Enemy planes
    var skyEnemy = SKSpriteNode()
    
    // Sky nodes
    var badCloud = SKSpriteNode()
    var powerUp = SKSpriteNode()
    var skyCoins = SKSpriteNode()
    
    // Player's weapons
    var bullets = SKSpriteNode()
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
    
    // Timers for spawn / interval / delays
    var timer = Timer()
    var wingTimer = Timer()
    var coinsTimer = Timer()
    var enemyTimer = Timer()
    var enemyShoots = Timer()
    var cloudTimer  = Timer()
    var explosions  = Timer()
    var powerUpTimer = Timer()
    
    // Game metering GUI
    var score = 0
    var powerUpCount = 0
    var coinCount = 0
    var health = 20
    var playerHP = maxHealth
    var gameOver = Bool()
    var gamePaused = Bool()
    var gameStarted = Bool()
    
    // Labels and images
    var healthLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var powerUpLabel = SKLabelNode()
    var coinImage = SKSpriteNode()
    var coinCountLbl = SKLabelNode()
    var display = SKSpriteNode()
    var pauseNode = SKSpriteNode()
    var pauseButton = SKSpriteNode()
    var darkenLayer: SKSpriteNode?
    var gameOverLabel: SKLabelNode?
    
    
    /********************************** didMoveToView Function **********************************/
    // MARK: - didMoveToView
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
//        if gameStarted == false {
//            
//            gameStarted = true
        
            // Backgroung color set with RGB
            backgroundColor = SKColor.init(red: 127/255, green: 189/255, blue: 248/255, alpha: 1.0)
            
            // Sets the physics delegate and physics body
            self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
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
            createPlane()
            
            
            /********************************* Spawn Timers *********************************/
            // MARK: - Spawn Timers
            
            // Spawning bullets timer call
            timer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(GameScene.spawnBullets), userInfo: nil, repeats: false)
            
            // Spawning wingmen timer call
            wingTimer = Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: #selector(GameScene.spawnWingman), userInfo: nil, repeats: true)
            
            // Spawning wingmen timer call
            wingTimer = Timer.scheduledTimer(timeInterval: 12.0, target: self, selector: #selector(GameScene.spawnBomber), userInfo: nil, repeats: true)
            
            // Spawning enemies timer call
            enemyTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(GameScene.spawnEnemyPlane), userInfo: nil, repeats: true)
            
            // Spawning enemy fire timer call
            enemyShoots = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(GameScene.spawnEnemyFire), userInfo: nil, repeats: true)
            
            // Set enemy tank spawn intervals
            coinsTimer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(GameScene.spawnCoins), userInfo: nil, repeats: true)
            
            // Spawning enemy fire timer call
            powerUpTimer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(GameScene.spawnPowerUps), userInfo: nil, repeats: true)
            
            // Cloud sound timer will for 12 sec and stop, then run again
            cloudTimer = Timer.scheduledTimer(timeInterval: 24.0, target: self, selector: #selector(GameScene.rainBadCloud), userInfo: nil, repeats: true)
            
            
            /********************************* Preloading Sound & Music *********************************/
            // MARK: - Spawning
            
            // After import AVFoundation, needs do,catch statement to preload sound so no delay
            do {
                let sounds = ["intro", "coin", "startGame", "bgMusic", "biplaneFlying", "gunfire", "mortar", "crash", "powerUp", "skyBoom", "planesFight", "planeMachineGun", "bGCannons", "tank", "prop", "airplaneFlyBy", "airplanep51", "mp5Gun"]
                
                for sound in sounds {
                    let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: sound, ofType: "mp3")!))
                    
                    player.prepareToPlay()
                }
            } catch {
                print("AVAudio has had an \(error).")
            }
            
            // Adds background sound to game
            bgMusic = SKAudioNode(fileNamed: "bgMusic")
            bgMusic.run(SKAction.play())
            bgMusic.autoplayLooped = false
            bgMusic.removeFromParent()
            self.addChild(bgMusic)
            
            biplaneFlyingSound = SKAudioNode(fileNamed: "biplaneFlying")
            biplaneFlyingSound.run(SKAction.play())
            biplaneFlyingSound.autoplayLooped = true
            
            biplaneFlyingSound.removeFromParent()
            self.addChild(biplaneFlyingSound)
//        }
    }
    
    
    /********************************** Simulating Physics ***************************************/
    // MARK: - Simulate Physics
    
    override func didSimulatePhysics() {
        
    }
    
    
    /********************************* touchesBegan Function **************************************/
    // MARK: - touchesBegan
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        touchLocation = touches.first!.location(in: self)
        
        for touch: AnyObject in touches {
            let location = (touch as! UITouch).location(in: self)
            
            /* Allows to tap on screen and plane will present
             at that axis and shoot at point touched */
            myPlane.position.y = location.y // Allows a tap to touch on the y axis
            myPlane.position.x = location.x // Allows a tap to touch on the x axis
            
            // Introduces the pause feature
            
            createHUD() /* function opens up the HUD and makes the button accessible
             also, has displays for health and score. */
            
            let node = self.atPoint(location)
            if (node.name == "PauseButton") || (node.name == "PauseButtonContainer") {
                showPauseAlert()
            }
            
            // Counts number of enemies
            if let theName = self.atPoint(location).name {
                if theName == "Enemy" {
                    self.removeChildren(in: [self.atPoint(location)])
                    score += 1
                }
            }
            
            if (gameOver == true) { // If goal is hit - game is completed
                checkIfGameIsOver()
            }
        }
    }
    
    
    /********************************* touchesMoved Function **************************************/
    // MARK: - touchesMoved
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = touches.first!.location(in: self)
        
        for touch: AnyObject in touches {
            let location = (touch as! UITouch).location(in: self)
            
            /* Allows to drag on screen and plane will follow
            that axis and shoot at point when released */
            myPlane.position.y = location.y // Allows a tap to touch on the y axis
            myPlane.position.x = location.x
            
        }
    }
    
    
    /********************************* touchesEnded Function **************************************/
    // MARK: - touchesEnded
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Each node will collide with the equalled item due to bit mask
        
        // Spawning bullets for our player
        bullets.isHidden = false
        spawnBullets()
        
        // Add sound to firing
        gunfireSound = SKAudioNode(fileNamed: "gunfire")
        gunfireSound.run(SKAction.play())
        gunfireSound.autoplayLooped = false
        
        self.addChild(gunfireSound)
        bgMusic.run(SKAction.pause())
    }
    
    
    /*********************************** Update Function *****************************************/
    // MARK: - Update Function
    
    // HUD for health meter
    override func update(_ currentTime: TimeInterval) {
        
        if !self.gamePaused { // Starts game in pause!!!!!!!
            holdGame()
            self.scene!.view?.isPaused = false
        }
        
        bgMusic.run(SKAction.play())
        
        // Move backgrounds
        moveBackground()
        moveMidground()
        moveForeground()
        
        // Healthbar GUI
        playerHealthBar.position = CGPoint(x: myPlane.position.x, y: myPlane.position.y - myPlane.size.height / 2 - 5)
        updateHealthBar(playerHealthBar, withHealthPoints: playerHP)
        
        // Adding to gameplay health attributes
        healthLabel.text = "Health: \(health)"
        
        // Changes health label red if too low
        if(health <= 3) {
            healthLabel.fontColor = SKColor.red
        }
    }
    

    /************************************ didBeginContact *****************************************/
    // MARK: - didBeginContact
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("PLANE HAS CONTACT")
        
        var contactBody1: SKPhysicsBody
        var contactBody2: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            contactBody1 = contact.bodyA
            contactBody2 = contact.bodyB
        } else {
            contactBody1 = contact.bodyB
            contactBody2 = contact.bodyA
        }
        
        // MyBullet VS
        if((contactBody1.categoryBitMask == 2) && (contactBody2.categoryBitMask == 8)) {
            explosion = SKEmitterNode(fileNamed: "FireExplosion")!
            smoke = SKEmitterNode(fileNamed: "Smoke")!
            
            explosion.position = (contactBody2.node?.position)!
            smoke.position = (contactBody2.node?.position)!
            
            self.addChild(explosion)
            self.addChild(smoke)
            
            contactBody2.node?.removeFromParent()
            contactBody1.node?.removeFromParent()
            
            crashSound.run(SKAction.play())
            crashSound.autoplayLooped = false
            crashSound.removeFromParent()
            self.addChild(crashSound)
            
            // Hitting an the enemy adds score and health
            score += 10
            health += 2
            playerHP = max(0, health + 2)
        }
        else if ((contactBody1.categoryBitMask == 2) && (contactBody2.categoryBitMask == 64)) {
            explode = SKEmitterNode(fileNamed: "Explode")!
            explode.position = (contactBody2.node?.position)!
            
            explode.removeFromParent()
            self.addChild(explode)
            
            contactBody1.node?.removeFromParent()
            contactBody2.node?.removeFromParent()
            
            // Calling pre-loaded sound to the star hits
            powerUpSound = SKAudioNode(fileNamed: "powerUp")
            powerUpSound.run(SKAction.play())
            powerUpSound.autoplayLooped = false
            
            powerUpSound.removeFromParent()
            self.addChild(powerUpSound)
            
            // Points per star added to score and 1 health
            score += 5
            health += 10
            playerHP = max(0, health + 10)
            powerUpCount += 1
        }
        else if ((contactBody1.categoryBitMask == 2) && (contactBody2.categoryBitMask == 128)) {
            explode = SKEmitterNode(fileNamed: "Explode")!
            explode.position = (contactBody2.node?.position)!
            
            explode.removeFromParent()
            self.addChild(explode)
            
            contactBody1.node?.removeFromParent()
            contactBody2.node?.removeFromParent()
            
            // Calling pre-loaded sound to the star hits
            coinSound = SKAudioNode(fileNamed: "coin")
            coinSound.run(SKAction.play())
            coinSound.autoplayLooped = false
            coinSound.removeFromParent()
            self.addChild(coinSound)
            
            // Points per star added to score and 1 health
            score += 5
            coinCount += 1
        }
        
        // MyPlane VS
        else if ((contactBody1.categoryBitMask == 4) && (contactBody2.categoryBitMask == 1)) {
            explosion = SKEmitterNode(fileNamed: "FireExplosion")!
            smoke = SKEmitterNode(fileNamed: "Smoke")!
            
            explosion.position = (contactBody1.node?.position)!
            smoke.position = (contactBody1.node?.position)!
            
            self.addChild(explosion)
            self.addChild(smoke)
            
            explosion.removeFromParent()
            smoke.removeFromParent()
            
            contactBody1.node?.removeFromParent()
            
            crashSound = SKAudioNode(fileNamed: "crash")
            crashSound.run(SKAction.play())
            crashSound.autoplayLooped = false
            
            crashSound.removeFromParent()
            self.addChild(crashSound)
        }
        else if ((contactBody1.categoryBitMask == 4) && (contactBody2.categoryBitMask == 8)) {
            explosion = SKEmitterNode(fileNamed: "FireExplosion")!
            smoke = SKEmitterNode(fileNamed: "Smoke")!
            
            self.addChild(explosion)
            self.addChild(smoke)
            
            explosion.position = contactBody2.node!.position
            smoke.position = contactBody2.node!.position
            
            contactBody2.node!.removeFromParent()
            
            crashSound = SKAudioNode(fileNamed: "crash")
            crashSound.run(SKAction.play())
            crashSound.autoplayLooped = false
            
            crashSound.removeFromParent()
            self.addChild(crashSound)
            
            health -= 10
            score += 5
            playerHP = max(0, health - 10)
        }
        else if ((contactBody1.categoryBitMask == 4) && (contactBody2.categoryBitMask == 16)) {
            explosion = SKEmitterNode(fileNamed: "FireExplosion")!
            
            explosion.position = contactBody1.node!.position
            self.addChild(explosion)
            
            contactBody2.node!.removeFromParent()
            
            crashSound = SKAudioNode(fileNamed: "crash")
            crashSound.run(SKAction.play())
            crashSound.autoplayLooped = false
            
            crashSound.removeFromParent()
            self.addChild(crashSound)
            
            health -= 5
            playerHP = max(0, health - 5)
        }
        else if ((contactBody1.categoryBitMask == 4) && (contactBody2.categoryBitMask == 64)) {
            explode = SKEmitterNode(fileNamed: "Explode")!
            explode.position = contactBody2.node!.position
            
            self.addChild(explode)
            
            contactBody2.node!.removeFromParent()
            
            // Calling pre-loaded sound to the star hits
            powerUpSound = SKAudioNode(fileNamed: "powerUp")
            powerUpSound.run(SKAction.play())
            powerUpSound.autoplayLooped = false
            
            powerUpSound.removeFromParent()
            self.addChild(powerUpSound)
            
            // Points per star added to score and health
            score += 5
            health += 10
            powerUpCount += 1
            playerHP = max(0, health + 10)
        }
        else if ((contactBody1.categoryBitMask == 4) && (contactBody2.categoryBitMask == 512)) {
            explosion = SKEmitterNode(fileNamed: "FireExplosion")!
            smoke = SKEmitterNode(fileNamed: "Smoke")!
            
            explosion.position = contactBody1.node!.position
            smoke.position = contactBody1.node!.position
            
            explosion.removeFromParent()
            smoke.removeFromParent()
            self.addChild(explosion)
            self.addChild(smoke)
            
            crashSound = SKAudioNode(fileNamed: "crash")
            crashSound.run(SKAction.play())
            crashSound.autoplayLooped = false
            crashSound.removeFromParent()
            self.addChild(crashSound)
            
            // Sky bomb hits us - we lose health
            health -= 10
            playerHP = max(0, health - 10)
        }
            
        // VS Enemy
        else if ((contactBody1.categoryBitMask == 8) && (contactBody2.categoryBitMask == 512)) {
            explosion = SKEmitterNode(fileNamed: "FireExplosion")!
            smoke = SKEmitterNode(fileNamed: "Smoke")!
            
            explosion.position = contactBody1.node!.position
            smoke.position = contactBody1.node!.position
            
            explosion.removeFromParent()
            smoke.removeFromParent()
            self.addChild(explosion)
            self.addChild(smoke)
            
            contactBody1.node!.removeFromParent()
            
            crashSound = SKAudioNode(fileNamed: "crash")
            crashSound.run(SKAction.play())
            crashSound.autoplayLooped = false
            
            crashSound.removeFromParent()
            self.addChild(crashSound)
            
            // Sky bomb hits enemy - we get points
            score += 3
        }
    }
    

    /********************************* Background Functions *********************************/
    // MARK: - Background Functions
    
    // Adding scrolling background
    func createBackground() {
        let myBackground = SKTexture(imageNamed: "clouds")
        
        for i in 0...1 {
            let background = SKSpriteNode(texture: myBackground)
            background.name = "Background"
            background.zPosition = -30
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: (myBackground.size().width * CGFloat(i)) - CGFloat(1 * i), y: 0)
            addChild(background)
        }
    }
    
    // Puts createMyBackground in motion
    func moveBackground() {
        
        self.enumerateChildNodes(withName: "Background", using: ({
            (node, error) in
            
            node.position.x -= 0.5
            
            if node.position.x < -((self.scene?.size.width)!) {
                
                node.position.x += (self.scene?.size.width)! * 2
            }
        }))
    }

    // Adding scrolling midground
    func createMidground() {
        let midground1 = SKTexture(imageNamed: "mountains")
        
        for i in 0...1 {
            let ground = SKSpriteNode(texture: midground1)
            ground.name = "Midground"
            ground.zPosition = -20
            ground.position = CGPoint(x: (midground1.size().width / 2.0 + (midground1.size().width * CGFloat(i))), y: midground1.size().height / 2)
            
            // Create physics body
            ground.physicsBody?.affectedByGravity = false
            
            self.addChild(ground)
        }
    }
    
    // Puts createMyMidground in motion
    func moveMidground() {
        
        self.enumerateChildNodes(withName: "Midground", using: ({
            (node, error) in
            
            node.position.x -= 1.0
            
            if node.position.x < -((self.scene?.size.width)!) {
                
                node.position.x += (self.scene?.size.width)! * 2
            }
        }))
    }
    
    // Adding scrolling foreground
    func createForeground() {
        let foreground = SKTexture(imageNamed: "lonelytree")
        
        for i in 0...1 {
            let ground = SKSpriteNode(texture: foreground)
            ground.name = "Foreground"
            ground.zPosition = 0
            ground.position = CGPoint(x: (foreground.size().width / 2.0 + (foreground.size().width * CGFloat(i))), y: foreground.size().height / 2)
            
            self.addChild(ground)
            
            // Create physics body
            ground.physicsBody?.isDynamic = false
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground1
            ground.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane4
            ground.physicsBody?.collisionBitMask = PhysicsCategory.Ground1
        }
    }
    
    // Puts createMyForeground in motion
    func moveForeground() {
        
        self.enumerateChildNodes(withName: "Foreground", using: ({
            (node, error) in
            
            node.position.x -= 2.0
            
            if node.position.x < -((self.scene?.size.width)!) {
                
                node.position.x += (self.scene?.size.width)! * 2
            }
        }))
    }
    
    
    /*********************************** Animation Functions *********************************/
    // MARK: - Plane animation functions
    
    func createPlane() {
        
        for i in 1...airplanesAtlas.textureNames.count { // Iterates loop for plane animation
            let plane = "MyFokker\(i)"
            planeArray.append(SKTexture(imageNamed: plane))
        }
        
        // Add user's animated bi-plane
        myPlane = SKSpriteNode(imageNamed: airplanesAtlas.textureNames[0])
        myPlane.setScale(0.7)
        myPlane.zPosition = 6
        myPlane.position = CGPoint(x: self.size.width / 6, y: self.size.height / 2)
        self.addChild(myPlane)
        
        // Body physics of player's plane
        myPlane.physicsBody = SKPhysicsBody(rectangleOf: myPlane.size)
        myPlane.physicsBody?.affectedByGravity = false
        myPlane.physicsBody?.categoryBitMask = PhysicsCategory.MyPlane4
        myPlane.physicsBody?.collisionBitMask = PhysicsCategory.Enemy8 | PhysicsCategory.EnemyFire16 | PhysicsCategory.Ground1 | PhysicsCategory.Coins128 | PhysicsCategory.PowerUp64
        myPlane.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy8 | PhysicsCategory.Ground1 | PhysicsCategory.EnemyFire16
        myPlane.physicsBody?.isDynamic = false
        
        myPlane.run(SKAction.repeatForever(SKAction.animate(with: planeArray, timePerFrame: 0.05)))
    }
    
    
    /*********************************** Spawning Functions *********************************/
    // MARK: - Spawning Functions
    
    // Spawn bullets for player's plane
    func spawnBullets() {
        
        // Setup bullet node
        bullets = SKSpriteNode(imageNamed: "Bullet")
        bullets.setScale(0.2)
        bullets.zPosition = 5
        
        bullets.position = CGPoint(x: myPlane.position.x + 50, y: myPlane.position.y)
        
        // Body physics of player's bullets
        bullets.physicsBody = SKPhysicsBody(rectangleOf: bullets.size)
        bullets.physicsBody?.affectedByGravity = false
        bullets.physicsBody?.categoryBitMask = PhysicsCategory.MyBullets2
        bullets.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy8 | PhysicsCategory.PowerUp64 | PhysicsCategory.Cloud32 | PhysicsCategory.Coins128
        bullets.physicsBody?.collisionBitMask = PhysicsCategory.Enemy8 | PhysicsCategory.PowerUp64 | PhysicsCategory.Cloud32 | PhysicsCategory.Coins128
        bullets.physicsBody?.usesPreciseCollisionDetection = true
        bullets.physicsBody?.isDynamic = false
        
        // Shoot em up!
        let action = SKAction.moveTo(x: self.size.width + 150, duration: 0.5)
        let actionDone = SKAction.removeFromParent()
        bullets.run(SKAction.sequence([action, actionDone]))
        
        self.addChild(bullets)
    }
    
    // Adding ally forces in background
    func spawnWingman() {
        
        // Alternate wingmen 1 of 2 passby's in the distance
        wingman = SKSpriteNode(imageNamed: "Fokker")
        wingman.zPosition = -19
        wingman.setScale(0.5)
        
        // Calculate random spawn points for wingmen
        let random = CGFloat(arc4random_uniform(1000) + 400)
        wingman.position = CGPoint(x: -self.size.width, y: random)
        
        // Body physics for player's wingmen
        wingman.physicsBody = SKPhysicsBody(rectangleOf: wingman.size)
        wingman.physicsBody?.affectedByGravity = false
        wingman.physicsBody?.isDynamic = false
        
        // Move wingmen forward
        let action = SKAction.moveTo(x: self.size.width + 50, duration: 18.0)
        let actionDone = SKAction.removeFromParent()
        wingman.run(SKAction.sequence([action, actionDone]))
        
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
        bomber.physicsBody = SKPhysicsBody(rectangleOf: bomber.size)
        bomber.physicsBody?.affectedByGravity = false
        bomber.physicsBody?.isDynamic = false
        
        // Move bomber forward
        let action = SKAction.moveTo(x: self.size.width + 80, duration: 22.0)
        let actionDone = SKAction.removeFromParent()
        bomber.run(SKAction.sequence([action, actionDone]))
        
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
        
        // Add enemies
        enemy1.removeFromParent()
        enemy2.removeFromParent()
        enemy3.removeFromParent()
        enemy4.removeFromParent()
        randomEnemy.removeFromParent()
        self.addChild(randomEnemy) // Generate the random enemy
        
        // Body physics for enemy's planes
        randomEnemy.physicsBody = SKPhysicsBody(rectangleOf: randomEnemy.size)
        randomEnemy.physicsBody?.affectedByGravity = false
        randomEnemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy8
        randomEnemy.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane4 | PhysicsCategory.MyBullets2 | PhysicsCategory.Enemy8 | PhysicsCategory.EnemyFire16
        randomEnemy.physicsBody?.collisionBitMask = PhysicsCategory.MyPlane4 | PhysicsCategory.MyBullets2 | PhysicsCategory.Enemy8 | PhysicsCategory.EnemyFire16
        randomEnemy.physicsBody?.isDynamic = false

        // Move enemies forward
        let action = SKAction.moveTo(x: -200, duration: 4.0)
        let actionDone = SKAction.removeFromParent()
        randomEnemy.run(SKAction.sequence([action, actionDone]))
        
        // Add sound
        airplaneFlyBySound = SKAudioNode(fileNamed: "airplaneFlyBy")
        airplaneFlyBySound.run(SKAction.play())
        airplaneFlyBySound.autoplayLooped = false
        airplaneFlyBySound.removeFromParent()
        self.addChild(airplaneFlyBySound)// Alternative sounds to choose from

        spawnEnemyFire()
    }

    func spawnEnemyFire() {
        enemyFire = SKSpriteNode(imageNamed: "Bullet")
        enemyFire.setScale(0.2)
        enemyFire.zPosition = -5
        enemyFire.xScale = node.xScale * -1

        enemyFire.position = CGPoint(x: randomEnemy.position.x - 75, y: randomEnemy.position.y)
        
        self.addChild(enemyFire) // Generate enemy fire

        // Body physics of player's bullets
        enemyFire.physicsBody = SKPhysicsBody(rectangleOf: enemyFire.size)
        enemyFire.physicsBody?.categoryBitMask = PhysicsCategory.EnemyFire16
        enemyFire.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane4 | PhysicsCategory.Enemy8 | PhysicsCategory.MyBullets2 | PhysicsCategory.Coins128
        enemyFire.physicsBody?.collisionBitMask = PhysicsCategory.MyPlane4 | PhysicsCategory.Enemy8 | PhysicsCategory.MyBullets2 | PhysicsCategory.Cloud32 | PhysicsCategory.PowerUp64
        enemyFire.name = "EnemyFire"
        enemyFire.physicsBody?.isDynamic = false
        enemyFire.physicsBody?.affectedByGravity = false
        
        // Change attributes
        enemyFire.color = UIColor.yellow
        enemyFire.colorBlendFactor = 1.0
        
        // Shoot em up!
        let action = SKAction.moveTo(x: -30, duration: 1.0)
        let actionDone = SKAction.removeFromParent()
        enemyFire.run(SKAction.sequence([action, actionDone]))
        
        // Add gun sound
        mp5GunSound = SKAudioNode(fileNamed: "mp5Gun")
        mp5GunSound.run(SKAction.play())
        mp5GunSound.autoplayLooped = false
        
        mp5GunSound.removeFromParent()
        self.addChild(mp5GunSound)
    }
    
    // Spawn sky nodes
    func skyExplosions() {
        
        // Sky explosions of a normal battle
        explosion = SKEmitterNode(fileNamed: "FireExplosion")!
        explosion.particleLifetime = 0.5
        explosion.particleScale = 0.4
        explosion.particleSpeed = 1.5
        explosion.zPosition = 9
        
        let xPos = randomBetweenNumbers(0, secondNum: frame.width )
        
        // Sky bomb position on screen
        explosion.position = CGPoint(x: xPos, y: self.frame.size.height * 0.25)
        
        self.addChild(explosion)
        
        // Physics for sky bomb
        explosion.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        explosion.physicsBody?.categoryBitMask = PhysicsCategory.SkyBombs512
        explosion.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane4 | PhysicsCategory.Enemy8
        explosion.physicsBody?.collisionBitMask = PhysicsCategory.MyPlane4 | PhysicsCategory.Enemy8
        explosion.name = "SkyBomb"
        explosion.physicsBody?.isDynamic = false
        explosion.physicsBody?.affectedByGravity = false
        
        skyBoomSound = SKAudioNode(fileNamed: "skyBoom")
        skyBoomSound.run(SKAction.play())
        skyBoomSound.autoplayLooped = false
        
        skyBoomSound.removeFromParent()
        self.addChild(skyBoomSound)
    }
    
    // Spawning coins
    func spawnCoins() {
        
        // Loop to run through .png's for animation
        for i in 1...assetsAtlas.textureNames.count {
            let coins = "Coin_\(i)"
            animationFrames.append(SKTexture(imageNamed: coins))
        }
        
        // Add user's animated coins
        skyCoins = SKSpriteNode(imageNamed: assetsAtlas.textureNames[0])
        
        let xPos = randomBetweenNumbers(0, secondNum: frame.width )
        
        // Star position off screen
        skyCoins.position = CGPoint(x: xPos, y: self.frame.size.height * 0.25)
        skyCoins.setScale(1.0)
        skyCoins.zPosition = 110
        
        self.addChild(skyCoins)
        
        // Added skyCoins physics
        skyCoins.physicsBody = SKPhysicsBody(edgeLoopFrom: powerUp.frame)
        skyCoins.physicsBody?.categoryBitMask = PhysicsCategory.Coins128
        skyCoins.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane4 | PhysicsCategory.MyBullets2 | PhysicsCategory.Enemy8 | PhysicsCategory.EnemyFire16
        skyCoins.physicsBody?.collisionBitMask = PhysicsCategory.MyBullets2 | PhysicsCategory.EnemyFire16
        skyCoins.physicsBody?.isDynamic = false
        skyCoins.physicsBody?.affectedByGravity = false
        
        // Add sound
        coinSound = SKAudioNode(fileNamed: "coin")
        coinSound.run(SKAction.play())
        coinSound.autoplayLooped = false
        coinSound.removeFromParent()
        self.addChild(coinSound)
    }
    
    // Spawning a bonus star
    func spawnPowerUps() {
        
        // Loop to run through .png's for animation
        for i in 1...assetsAtlas.textureNames.count {
            let powerUp = "life_power_up_\(i)"
            animationFrames.append(SKTexture(imageNamed: powerUp))
        }
        
        // Add user's animated powerUp
        powerUp = SKSpriteNode(imageNamed: assetsAtlas.textureNames[0])
        
        let xPos = randomBetweenNumbers(0, secondNum: frame.width )
        
        // Star position off screen
        powerUp.position = CGPoint(x: xPos, y: self.frame.size.height * 0.25)
        powerUp.setScale(0.9)
        powerUp.zPosition = 11
        
        powerUp.removeFromParent()
        self.addChild(powerUp)
        
        // Added star's physics
        powerUp.physicsBody = SKPhysicsBody(edgeLoopFrom: powerUp.frame)
        powerUp.physicsBody?.categoryBitMask = PhysicsCategory.PowerUp64
        powerUp.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane4 | PhysicsCategory.MyBullets2 | PhysicsCategory.Enemy8 | PhysicsCategory.EnemyFire16
        powerUp.physicsBody?.collisionBitMask = PhysicsCategory.MyBullets2 | PhysicsCategory.EnemyFire16
        powerUp.physicsBody?.isDynamic = false
        powerUp.physicsBody?.affectedByGravity = false
        
        // Add sound
        powerUpSound = SKAudioNode(fileNamed: "powerUp")
        powerUpSound.run(SKAction.play())
        powerUpSound.autoplayLooped = false
        powerUpSound.removeFromParent()
        self.addChild(powerUpSound)
    }
    
    // Introducing the cloud using linear interpolation
    func cloudOnAPath() {
        
        badCloud = SKSpriteNode(imageNamed: "badCloud")
        badCloud.zPosition = -21
        
        // Randomly place cloud on Y axis
        let actualY = CGFloat.random(min: 400, max: self.frame.size.height - 100)
        
        // Clouds position off screen
        badCloud.position = CGPoint(x: size.width + badCloud.size.width / 2, y: actualY)
        
        // This time I will determine speed by velocity rather than time interval
        let actualDuration = CGFloat.random(min: CGFloat(10.0), max: CGFloat(15.0))
        
        self.addChild(badCloud) // Generate "bonus" star
        
        // Added star's physics
        badCloud.physicsBody = SKPhysicsBody(edgeLoopFrom: badCloud.frame)
        badCloud.physicsBody?.affectedByGravity = false
        badCloud.physicsBody?.categoryBitMask = PhysicsCategory.Cloud32
        badCloud.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane4 | PhysicsCategory.MyBullets2
        badCloud.physicsBody?.collisionBitMask = 256
        badCloud.physicsBody?.isDynamic = false
        
        // Create a path func cloudOnAPath() {
        let actionMove = SKAction.move(to: CGPoint(x: -badCloud.size.width / 2, y: actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        badCloud.run(SKAction.sequence([actionMove, actionMoveDone]))
        
        badCloud.shadowCastBitMask = 1
        badCloud.lightingBitMask = 1
        
        // Put bad cloud on a linear interpolation path
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run(cloudOnAPath),
            SKAction.wait(forDuration: 12.0)
            ])
            ))
    }
    
    func randomBetweenNumbers(_ firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    

    /*********************************** Emitter Functions *********************************/
    // MARK: - Emitter Functions
    
    // Adding emitter to follow cloud and rain in time intervals
    func rainBadCloud() {
        
        // Cloud will rain within intervals
        rain = SKEmitterNode(fileNamed: "Rain")
        rain!.zPosition = -29.5
        rain!.setScale(0.8)
        
        // Set physics for rain
        rain!.physicsBody?.affectedByGravity = false
        rain!.physicsBody?.categoryBitMask = PhysicsCategory.Rain256
        rain!.physicsBody?.contactTestBitMask = PhysicsCategory.MyPlane4 | PhysicsCategory.Enemy8 | PhysicsCategory.EnemyFire16 | PhysicsCategory.PowerUp64 | PhysicsCategory.Coins128
        rain!.physicsBody?.collisionBitMask = 2048
        
        // Follows cloud
        rain!.targetNode = self.scene
        badCloud.addChild(rain!)
    }
    
    // Healthbar function for visual display
    func updateHealthBar(_ node: SKSpriteNode, withHealthPoints hp: Int) {
        
        let barSize = CGSize(width: healthBarWidth, height: healthBarHeight);
        
        let fillColor = UIColor(red: 113.0/255, green: 202.0/255, blue: 53.0/255, alpha:1)
        let borderColor = UIColor(red: 35.0/255, green: 28.0/255, blue: 40.0/255, alpha:1)
        
        // create drawing context
        UIGraphicsBeginImageContextWithOptions(barSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // draw the outline for the health bar
        borderColor.setStroke()
        let borderRect = CGRect(origin: CGPoint.zero, size: barSize)
        context?.stroke(borderRect, width: 1)
        
        // draw the health bar with a colored rectangle
        fillColor.setFill()
        let barWidth = (barSize.width - 1) * CGFloat(hp) / CGFloat(maxHealth)
        let barRect = CGRect(x: 0.5, y: 0.5, width: barWidth, height: barSize.height - 1)
        context?.fill(barRect)
        
        // extract image
        let spriteImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // set sprite texture and size
        node.texture = SKTexture(image: spriteImage!)
        node.size = barSize
    }
    
    
    /*************************************** Pause ******************************************/
    
    // Show Pause Alert
    func showPauseAlert() {
        self.gamePaused = true
        let alert = UIAlertController(title: "Pause", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default)  { _ in
            self.gamePaused = false
            })
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func createHUD() {
        
        // Adding HUD with pause
        display = SKSpriteNode(color: UIColor.black, size: CGSize(width: self.size.width, height: self.size.height * 0.06))
        display.anchorPoint = CGPoint(x: 0, y: 0)
        display.position = CGPoint(x: 0, y: self.size.height - display.size.height)
        display.zPosition = 15
        
        // Pause button container
        pauseNode.position = CGPoint(x: display.size.width / 2, y: display.size.height / 2)
        pauseNode.size = CGSize(width: display.size.height * 3, height: display.size.height * 2.5)
        pauseNode.name = "PauseButtonContainer"
        
        // Pause button
        pauseButton = SKSpriteNode(imageNamed: "pause")
        pauseButton.zPosition = 1000
        pauseButton.size = CGSize(width: 75, height: 75)
        pauseButton.position = CGPoint(x: display.size.width / 2, y: display.size.height / 2 - 15)
        pauseButton.name = "PauseButton"
        
        // Health label
        healthLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        health = 20
        healthLabel.text = "Health: \(health)"
        healthLabel.fontSize = display.size.height
        healthLabel.fontColor = SKColor.white
        healthLabel.position = CGPoint(x: 25, y: display.size.height / 2 - 25)
        healthLabel.horizontalAlignmentMode = .left
        healthLabel.zPosition = 15
        
        // Power Up Health Hearts
        powerUp = SKSpriteNode(imageNamed: "life_power_up_1")
        powerUp.zPosition = 100
        powerUp.size = CGSize(width: 75, height: 75)
        powerUp.position = CGPoint(x: 75, y: display.size.height / 2 - 75)
        powerUp.name = "PowerUp"
        
        // Label to let user know the count of power ups
        powerUpLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        powerUpLabel.zPosition = 100
        powerUpCount = 0
        powerUpLabel.color = UIColor.red
        powerUpLabel.colorBlendFactor = 1.0
        powerUpLabel.text = " X \(powerUpCount)"
        powerUpLabel.fontSize = powerUp.size.height
        powerUpLabel.position = CGPoint(x: powerUp.frame.width + 125, y: display.size.height / 2 - 105)
        
        // Score label
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        score = 0
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = display.size.height
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: display.size.width - 30, y: display.size.height / 2 - 25)
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.zPosition = 15
        
        // Coin Image
        coinImage = SKSpriteNode(imageNamed: "Coin_1")
        coinImage.zPosition = 200
        coinImage.size = CGSize(width: 75, height: 75)
        coinImage.position = CGPoint(x: self.size.width - 200, y: display.size.height / 2 - 85)
        coinImage.name = "Coin"
        
        // Label to let user know the count of coins collected
        coinCountLbl = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        coinCountLbl.zPosition = 200
        coinCount = 0
        coinCountLbl.color = UIColor.yellow
        coinCountLbl.colorBlendFactor = 1.0
        coinCountLbl.text = " X \(coinCount)"
        coinCountLbl.fontSize = powerUp.size.height
        coinCountLbl.position = CGPoint(x: self.frame.width - 75, y: display.size.height / 2 - 115)
        
        self.addChild(display)
        pauseNode.removeFromParent()
        display.addChild(pauseNode)
        display.addChild(pauseButton)
        display.addChild(healthLabel)
        display.addChild(powerUp)
        display.addChild(powerUpLabel)
        display.addChild(scoreLabel)
        display.addChild(coinImage)
        display.addChild(coinCountLbl)
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
    
    // Displays the game over screen
    func showGameOverScreen(){
        gameOverLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        gameOverLabel!.text = "Game Over!  Score: \(score)"
        gameOverLabel!.fontColor = SKColor.red
        gameOverLabel!.fontSize = 65
        gameOverLabel!.position = CGPoint(x: self.frame.midX, y: self.frame.midY);
        self.addChild(gameOverLabel!)
    }
    
    func holdGame() {
        
        self.scene!.view?.isPaused = false
        
        // Stop movement, fade out, move to center, fade in
        myPlane.removeAllActions()
        self.myPlane.run(SKAction.fadeOut(withDuration: 1) , completion: {
            self.myPlane.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
            self.myPlane.run(SKAction.fadeIn(withDuration: 1), completion: {
                self.scene!.view?.isPaused = true
            })
        })
    }
}
