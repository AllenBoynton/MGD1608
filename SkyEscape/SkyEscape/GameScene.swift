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
    static let Ground      : UInt32 = 1  //0x1 << 0
    static let Player      : UInt32 = 2  //0x1 << 1
    static let MyBullets   : UInt32 = 4  //0x1 << 2
    static let Enemy       : UInt32 = 8  //0x1 << 3
    static let EnemyFire   : UInt32 = 8
    static let Cloud       : UInt32 = 16 //0x1 << 4
    static let StarMask    : UInt32 = 16
    static let Coins       : UInt32 = 16
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
var coinSound = SKAudioNode()
var thumpSound = SKAudioNode()
var thunderSound = SKAudioNode()
var crashSound = SKAudioNode()
var bombSound = SKAudioNode()
var bombDropSound = SKAudioNode()
var planesFightSound = SKAudioNode()
var bGCannonsSound = SKAudioNode()
var battleBGMusic = SKAudioNode()
var planeMGunSound = SKAudioNode()
var tankFiringSound = SKAudioNode()
var airplaneFlyBySound = SKAudioNode()
var airplaneP51Sound = SKAudioNode()


let MaxHealth = 100
let HealthBarWidth: CGFloat = 40
let HealthBarHeight: CGFloat = 4
let playerHealthBar = SKSpriteNode()

let DarkenOpacity: CGFloat = 0.8
let DarkenDuration: CFTimeInterval = 2


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let world = SKNode()
    let star = Star()
    let bronzeCoin = Coins()
    let goldCoin = Coins()
    let encounterManager = EncounterManager()
    
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
    var textureSprites: [SKTexture] = []
    var textureAtlas: SKTextureAtlas!
    var bullets = SKSpriteNode()
    var bombs = SKSpriteNode()
    
    // Sky nodes
    var badCloud = SKSpriteNode()
    var bomber = SKSpriteNode()
    var wingman = SKSpriteNode()
    var wingmanArray: [SKSpriteNode] = []
    
    // Enemy planes / Ground / weapons
    var enemy1 = SKSpriteNode()
    var enemy2 = SKSpriteNode()
    var enemy3 = SKSpriteNode()
    var enemy4 = SKSpriteNode()
    var enemyArray: [SKSpriteNode] = []
    var enemyFire = SKSpriteNode()
    var tank = SKSpriteNode()
    var missiles = SKSpriteNode()
    
    // Timers for spawn / interval / delays
    var timer = NSTimer()
    var wingTimer = NSTimer()
    var enemyTimer = NSTimer()
    var enemyShoots = NSTimer()
    var enemyTankTimer = NSTimer()
    var enemyTankShoots = NSTimer()
    
    // Game metering GUI
    var score = 0
    var starCount = 0
    var health = 10
    var playerHP = MaxHealth
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
    var darkenLayer: SKSpriteNode?
    var gameOverLabel: SKLabelNode?
    
    
    /********************************** didMoveToView Function **********************************/
    // MARK: - didMoveToView
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        // Sets the physics delegate and physics body
        physicsWorld.contactDelegate = self // Physics delegate set
        
        // Add the world node as a child of the scene:
        self.addChild(world)
        
        // Size our scene to fit the view exactly
        size = view.bounds.size
        
        
    /********************************* Adding Scroll Background *********************************/
    // MARK: - Scroll Background
        
        // Adding scrolling Main Background
        myBackground = SKSpriteNode(imageNamed: "cartoonCloudsBGLS")
        createBackground()
        
        // Adding a midground
        midground1 = SKSpriteNode(imageNamed: "mountain")
        midground2 = SKSpriteNode(imageNamed: "mountain")
        createMidground()
        
        foreground = SKSpriteNode(imageNamed: "lonelytree")
        createForeground()
        
    /*************************************** Spawning Nodes *************************************/
    // MARK: - Spawning
        
        // Utilizing encounter manager to introduce nodes to the scene
        encounterManager.addEncountersToWorld(self.world)
        encounterManager.encounters[0].position = CGPoint(x: 300, y: 0)
        
        // Adding our player's plane to the scene
        animateMyPlane()
        
        // Add background wingmen planes
        spawnWingmen()
        
        // The powerup star:
        star.spawn(world, position: CGPoint(x: 250, y: 250))
        
        // Adding the bronze coin - value = 1
        bronzeCoin.spawn(world, position: CGPoint(x: 490, y: 250))
        
        // Adding the gold coin - value = 5
        goldCoin.spawn(world, position: CGPoint(x: 460, y: 250))
        goldCoin.turnToGold()
        
        // Spawning random points for air enemies
        spawnEnemyPlane()
        
        // Spawning the tank
        spawnTank()
        
        // Spawning the missiles for enemy tank
        spawnTankMissiles()
        
        // Initilize values and labels
//        initializeValues()
    
        
    /********************************* Spawn Timers *********************************/
    // MARK: - Spawn Timers
        
        // Spawning bullets timer call
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(GameScene.spawnBullets), userInfo: nil, repeats: false)
        
        // Spawning winmen timer call
        wingTimer = NSTimer.scheduledTimerWithTimeInterval(6.0, target: self, selector: #selector(GameScene.spawnWingmen), userInfo: nil, repeats: true)
        
        // Spawning enemies timer call
        enemyTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(GameScene.spawnEnemyPlane), userInfo: nil, repeats: true)
        
        // Spawning enemy fire timer call
        enemyShoots = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(GameScene.spawnEnemyFire), userInfo: nil, repeats: true)
        
        // Set enemy tank spawn intervals
        enemyTankTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(GameScene.spawnTank), userInfo: nil, repeats: true)
        
        // Spawning tank missile timer call
        enemyTankShoots = NSTimer.scheduledTimerWithTimeInterval(8.0, target: myPlane, selector: #selector(GameScene.spawnTankMissiles), userInfo: nil, repeats: true)
        
        
    /********************************* Preloading Sound & Music *********************************/
    // MARK: - Spawning
        
        // After import AVFoundation, needs do,catch statement to preload sound so no delay
        do {
            let sounds = ["Coin", "Hurt", "Powerup", "StartGame", "bgMusic", "BattleTheme", "biplaneFlying", "gunfire", "star", "thump", "thunder", "crash", "bomb", "bombDrop", "planesFight", "planeMachineGun", "bGCannons", "tankFiring", "airplaneFlyBy", "airplane+p51"]
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
        bgMusic.autoplayLooped = true
        
        biplaneFlyingSound = SKAudioNode(fileNamed: "biplaneFlying")
        biplaneFlyingSound.runAction(SKAction.play())
        biplaneFlyingSound.autoplayLooped = true
        
//        self.addChild(bgMusic)
        self.addChild(biplaneFlyingSound)
    }
    
    
    /********************************** Simulating Physics ***************************************/
    // MARK: - Simulate Physics
    
    override func didSimulatePhysics() {
        let worldXPos = -(myPlane.position.x * world.xScale - (self.size.width / 2))
        let worldYPos = -(myPlane.position.y * world.yScale - (self.size.height / 2))
        world.position = CGPoint(x: worldXPos, y: worldYPos)
    }
    
    
    /*********************************** Update Function *****************************************/
    // MARK: - Update Function
    
    override func update(currentTime: NSTimeInterval) {
        // Healthbar GUI
        playerHealthBar.position = CGPoint(
            x: myPlane.position.x,
            y: myPlane.position.y - myPlane.size.height/2 - 15
        )
        
        updateHealthBar(playerHealthBar, withHealthPoints: playerHP)
        

        // Animating midground
        midground1.position = CGPoint(x: midground1.position.x - 4, y: 100)
        midground2.position = CGPoint(x: midground2.position.x - 4, y: midground2.position.y)
        
        if (midground1.position.x < -midground1.size.width + 200 / 2){
            midground1.position = CGPoint(x: midground2.position.x + midground2.size.width * 4, y: mtHeight)
        }
        
        if (midground2.position.x < -midground2.size.width + 200 / 2) {
            midground2.position = CGPoint(x: midground1.position.x + midground1.size.width * 4, y: mtHeight)
        }
        
        if (midground1.position.x < self.frame.width / 2) {
            mtHeight = randomNumbers(600, secondNum: 240)
        }
        
        //        checkIfPlaneGetsAcross()
        //        checkIfGameIsOver()
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
            
            // Spawning bullets for our player
            spawnBullets()
            bullets.hidden = false
            
            // Add sound to firing
            gunfireSound = SKAudioNode(fileNamed: "gunfire")
            gunfireSound.runAction(SKAction.play())
            gunfireSound.autoplayLooped = false
            self.addChild(gunfireSound)

            addGunfireToPlane()
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
        }
    }
    
    
    /********************************* touchesEnded Function **************************************/
    // MARK: - touchesEnded
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Each node will collide with the equalled item due to bit mask
        spawnBombs()
        bombs.hidden = false
        
        // Adding sound
        bombSound = SKAudioNode(fileNamed: "bomb")
        bombDropSound = SKAudioNode(fileNamed: "bombDrop")
        bombSound.runAction(SKAction.play())
        bombDropSound.runAction(SKAction.play())
        bombSound.autoplayLooped = false
        bombDropSound.autoplayLooped = false
        
//        self.addChild(bombSound)
//        self.addChild(bombDropSound)
    }
    // Want to use use a double tap or long press to drop bomb
    
    
    /************************************ didBeginContact *****************************************/
    // MARK: - didBeginContact
    
    func didBeginContact(contact: SKPhysicsContact) {
        print("PLANE HAS CONTACT")
        // Establish that badCloud has a bit mask
        /* Assigning bit collision for the cloud now -
         it does not have a block of code*/
        badCloud.physicsBody?.collisionBitMask = PhysicsCategory.Cloud
        
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB
        
        if ((firstBody.categoryBitMask == PhysicsCategory.Enemy) && (secondBody.categoryBitMask == PhysicsCategory.MyBullets) || (firstBody.categoryBitMask == PhysicsCategory.MyBullets) && (secondBody.categoryBitMask == PhysicsCategory.Enemy)) {
                didBulletsHitEnemy(firstBody.node as! SKSpriteNode, MyBullets: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Enemy) && (secondBody.categoryBitMask == PhysicsCategory.Player) || (firstBody.categoryBitMask == PhysicsCategory.Player) && (secondBody.categoryBitMask == PhysicsCategory.Enemy)) {
                self.didEnemyHitPlayer(firstBody.node as! SKSpriteNode, Player: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.EnemyFire) && (secondBody.categoryBitMask == PhysicsCategory.Player) || (firstBody.categoryBitMask == PhysicsCategory.Player) && (secondBody.categoryBitMask == PhysicsCategory.EnemyFire)) {
            self.didEnemyFireHitPlayer(firstBody.node as! SKSpriteNode, Player: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.MyBullets) && (secondBody.categoryBitMask == PhysicsCategory.StarMask) || (firstBody.categoryBitMask == PhysicsCategory.StarMask) && (secondBody.categoryBitMask == PhysicsCategory.MyBullets)) {
                self.didBulletsHitStar(firstBody.node as! SKSpriteNode, StarMask: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Player) && (secondBody.categoryBitMask == PhysicsCategory.StarMask) || (firstBody.categoryBitMask == PhysicsCategory.StarMask) && (secondBody.categoryBitMask == PhysicsCategory.Player)) {
                self.didPlayerHitStar(firstBody.node as! SKSpriteNode, StarMask: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.MyBullets) && (secondBody.categoryBitMask == PhysicsCategory.Cloud) || (firstBody.categoryBitMask == PhysicsCategory.Cloud) && (secondBody.categoryBitMask == PhysicsCategory.MyBullets)) {
                self.didBulletsHitCloud(firstBody.node as! SKSpriteNode, Cloud: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Player) && (secondBody.categoryBitMask == PhysicsCategory.Ground) || (firstBody.categoryBitMask == PhysicsCategory.Ground) && (secondBody.categoryBitMask == PhysicsCategory.Player)) {
                self.didPlayerHitGround(firstBody.node as! SKSpriteNode, Ground: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.MyBullets) && (secondBody.categoryBitMask == PhysicsCategory.Ground) || (firstBody.categoryBitMask == PhysicsCategory.Ground) && (secondBody.categoryBitMask == PhysicsCategory.MyBullets)) {
            self.didBulletsHitGround(firstBody.node as! SKSpriteNode, Ground: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.MyBullets) && (secondBody.categoryBitMask == PhysicsCategory.Coins) || (firstBody.categoryBitMask == PhysicsCategory.Coins) && (secondBody.categoryBitMask == PhysicsCategory.MyBullets)) {
            self.didBulletsHitCoins(firstBody.node as! SKSpriteNode, Coins: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Player) && (secondBody.categoryBitMask == PhysicsCategory.Coins) || (firstBody.categoryBitMask == PhysicsCategory.Coins) && (secondBody.categoryBitMask == PhysicsCategory.Player)) {
            self.didPlayerHitCoins(firstBody.node as! SKSpriteNode, Coins: secondBody.node as! SKSpriteNode)
        }
    }
    
    
    /***************************** Collision Functions *********************************/
    // MARK: - Collision Functions
    
    // Function if player hits enemy with weapon
    func didBulletsHitEnemy (Enemy: SKSpriteNode, MyBullets: SKSpriteNode) {
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        smoke = SKEmitterNode(fileNamed: "Smoke")
        explosion.position = Enemy.position
        smoke.position = Enemy.position
        
        Enemy.removeFromParent()
        MyBullets.removeFromParent()
        smokeTrail.removeFromParent()
        gunfire.removeFromParent()
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
        smokeTrail.removeFromParent()
        gunfire.removeFromParent()
        self.addChild(explosion)
        self.addChild(smoke)
        
        crashSound = SKAudioNode(fileNamed: "crash")
        crashSound.runAction(SKAction.play())
        crashSound.autoplayLooped = false
        self.addChild(crashSound)
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
        
        // Adds star to make sound
        StarMask.removeFromParent()
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
    
    // Function if player hit cloud with weapon
    func didBulletsHitCloud (MyBullets: SKSpriteNode, Cloud: SKSpriteNode) {
        rain = SKEmitterNode(fileNamed: "Rain")
        rain.position = Cloud.position
        rain.position = CGPointMake(badCloud.position.x, badCloud.position.y)
        
        MyBullets.removeFromParent()
        
        // Influenced by plane's movement
        rain.targetNode = self.scene
        badCloud.addChild(rain)
        
        thunderSound = SKAudioNode(fileNamed: "thump")
        thunderSound.runAction(SKAction.play())
        thumpSound.autoplayLooped = false
        self.addChild(thumpSound)
        
        score += 2
        health += 1
    }
    
    // Function if player hits the ground
    func didBulletsHitGround(MyBullets: SKSpriteNode, Ground: SKSpriteNode) {
        /* Enemy (including ground or obstacle) will
         emit explosion, smoke and sound when hit*/
        
        explosion = SKEmitterNode(fileNamed: "FireExplosion")
        explosion.position = MyBullets.position
        
        MyBullets.removeFromParent()
        self.addChild(explosion)
        
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
        
        // Adds star to make sound
        Coins.removeFromParent()
        MyBullets.removeFromParent()
        self.addChild(explode)
        
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
        
        // Adds star to make sound
        Coins.removeFromParent()
        self.addChild(explode)
        
        // Calling pre-loaded sound to the star hits
        coinSound = SKAudioNode(fileNamed: "Coin")
        coinSound.runAction(SKAction.play())
        coinSound.autoplayLooped = false
        self.addChild(coinSound)
        
        // Points per star added to score
        score += 2
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
        
        Player.removeFromParent()
        self.addChild(explosion)
        self.addChild(smoke)
        
        crashSound = SKAudioNode(fileNamed: "crash")
        crashSound.runAction(SKAction.play())
        crashSound.autoplayLooped = false
        self.addChild(crashSound)
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
            
            let moveLeft = SKAction.moveByX(-myBackground.size().width, y: 0, duration: 50)
            let moveReset = SKAction.moveByX(myBackground.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatActionForever(moveLoop)
            
            background.runAction(moveForever)
        }
    }

    // Adding scrolling midground
    func createMidground() {
        midground1.setScale(3.0)
        midground1.zPosition = 2
        midground1.position = CGPointMake(800, 200)
        midground1.size.height = midground1.size.height / 2
        midground1.size.width = midground1.size.width / 2
        
        // Physics bitmask for mountains
        midground1.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        midground1.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        
        midground2.position = CGPointMake(1600, 2000)
        midground2.setScale(3.0)
        midground2.zPosition = 2
        midground2.size.height = midground2.size.height / 2
        midground2.size.width = midground2.size.width / 2
        
        // Physics bitmask for mountains
        midground2.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        midground2.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        
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
            ground.zPosition = 30
            ground.position = CGPoint(x: (foreground.size().width / 2 + (foreground.size().width * CGFloat(i))), y: foreground.size().height / 2)
            
            // Create physics body
            ground.physicsBody = SKPhysicsBody(edgeLoopFromRect: ground.frame)
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
            ground.physicsBody?.contactTestBitMask = PhysicsCategory.Player
            ground.physicsBody?.dynamic = false
            
            self.addChild(ground)
            
            let moveLeft = SKAction.moveByX(-foreground.size().width, y: 0, duration: 10)
            let moveReset = SKAction.moveByX(foreground.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatActionForever(moveLoop)
            
            ground.shadowCastBitMask = 1
            
            ground.runAction(moveForever)
        }
    }
    
    
    /*********************************** Animation Functions *********************************/
    // MARK: - Plane animation functions
    
    func animateMyPlane() {
        textureAtlas = SKTextureAtlas(named: "Images.atlas")
        
        myPlane.setScale(0.2)
        myPlane.position = CGPoint(x: myPlane.size.width / 6, y: myPlane.size.height / 2)
        self.zPosition = 3
        
        // Body physics of player's plane
        myPlane.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        myPlane.physicsBody?.affectedByGravity = false
        myPlane.physicsBody?.categoryBitMask = PhysicsCategory.Player
        myPlane.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy | PhysicsCategory.Ground | PhysicsCategory.EnemyFire
        myPlane.physicsBody?.dynamic = false
        
        for i in 1...textureAtlas.textureNames.count { // Iterates loop for plane animation
            let plane = "myPlane\(i).png"
            textureSprites.append(SKTexture(imageNamed: plane))
        }
        
        self.addChild(myPlane)
        
        self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textureSprites, timePerFrame: 0.05)))
        bullets.hidden = true
        
        addSmokeTrail()
    }
    
    
    /*********************************** Spawning Functions *********************************/
    // MARK: - Spawning Functions
    
    // Adding ally forces in background
    func spawnWingmen() {
        wingman = SKSpriteNode(imageNamed: "wingman")
        bomber = SKSpriteNode(imageNamed: "bomber")
        
        wingmanArray = [wingman, bomber]
        
        for wing in wingmanArray {
            let minValue = self.size.height / 4
            let maxValue = self.size.height - 40
            let spawnPoints = UInt32(maxValue - minValue)
            wing.position = CGPoint(x: self.size.width, y: CGFloat(arc4random_uniform(spawnPoints) + 200))
            wing.setScale(0.1)
            wing.zPosition = 1
            wing.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
            wing.physicsBody?.affectedByGravity = false
            wing.physicsBody?.collisionBitMask = PhysicsCategory.Player
            wing.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy | PhysicsCategory.EnemyFire | PhysicsCategory.Ground
            wing.physicsBody?.dynamic = false
        }
        
        // Generate a random index
        let randomIndex = Int(arc4random_uniform(UInt32(wingmanArray.count)))
        
        let randomWingman = wingmanArray[randomIndex]
        
        self.addChild(randomWingman)
        
        // Move enemies forward
        let action = SKAction.moveToX(self.size.width + 100, duration: 6.0)
        let actionDone = SKAction.removeFromParent()
        randomWingman.runAction(SKAction.sequence([action, actionDone]))
    }
    
    // Spawn bullets for player's plane
    func spawnBullets() {
        bullets = SKSpriteNode(imageNamed: "silverBullet")
        bullets.setScale(0.1)
        bullets.position = CGPoint(x: self.position.x + 75, y: self.position.y)
        bullets.zPosition = 3
        
        // Body physics of player's bullets
        bullets.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        bullets.physicsBody?.affectedByGravity = false
        bullets.physicsBody?.collisionBitMask = PhysicsCategory.MyBullets
        bullets.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy | PhysicsCategory.StarMask | PhysicsCategory.Cloud
        bullets.physicsBody?.dynamic = false
        
        self.addChild(bullets)
        
        // Shoot em up!
        let action = SKAction.moveToX(self.size.width + 100, duration: 0.5)
        let actionDone = SKAction.removeFromParent()
        bullets.runAction(SKAction.sequence([action, actionDone]))
    }
    
    func spawnBombs() {
        bombs = SKSpriteNode(imageNamed: "bomb1")
        bombs.setScale(0.2)
        bombs.position = CGPoint(x: self.position.x, y: self.position.y - 100)
        bombs.zPosition = 3
        
        // Body physics of player's bullets
        bombs.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        bombs.physicsBody?.affectedByGravity = false
        bombs.physicsBody?.collisionBitMask = PhysicsCategory.MyBullets
        bombs.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy | PhysicsCategory.StarMask | PhysicsCategory.Cloud | PhysicsCategory.Ground
        bombs.physicsBody?.dynamic = false
        
        self.addChild(bombs)
        
        // Drop em!
        let action = SKAction.moveToY(self.size.height + 80, duration: 3.0)
        let actionDone = SKAction.removeFromParent()
        bombs.runAction(SKAction.sequence([action, actionDone]))
        
        bombs.hidden = true
    }
    
    // Generate enemy fighter planes
    func spawnEnemyPlane() {
        enemy1 = SKSpriteNode(imageNamed: "enemy1")
        enemy2 = SKSpriteNode(imageNamed: "enemy2")
        enemy3 = SKSpriteNode(imageNamed: "enemy3")
        enemy4 = SKSpriteNode(imageNamed: "enemy4")
        
        enemyArray = [enemy1, enemy2, enemy3, enemy4]
        
        for enemy in enemyArray {
            let minValue = self.size.height / 4
            let maxValue = self.size.height - 40
            let spawnPoints = UInt32(maxValue - minValue)
            enemy.position = CGPoint(x: self.size.width, y: CGFloat(arc4random_uniform(spawnPoints) + 200))
            enemy.setScale(0.18)
            enemy.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
            enemy.physicsBody?.affectedByGravity = false
            enemy.physicsBody?.collisionBitMask = PhysicsCategory.Enemy
            enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.MyBullets | PhysicsCategory.Enemy | PhysicsCategory.EnemyFire
            enemy.physicsBody?.dynamic = true
        }
        
        // Generate a random index
        let randomIndex = Int(arc4random_uniform(UInt32(enemyArray.count)))
        
        let randomEnemy = enemyArray[randomIndex]
        
        self.addChild(randomEnemy)
        
        // Move enemies forward
        let action = SKAction.moveToX(self.size.width - 100, duration: 3.5)
        let actionDone = SKAction.removeFromParent()
        randomEnemy.runAction(SKAction.sequence([action, actionDone]))
        
        // Add sound
        airplaneFlyBySound = SKAudioNode(fileNamed: "airplaneFlyBy")
        airplaneFlyBySound.runAction(SKAction.play())
        airplaneFlyBySound.autoplayLooped = false
        
        airplaneP51Sound = SKAudioNode(fileNamed: "airplane+p51")
        airplaneP51Sound.runAction(SKAction.play())
        airplaneP51Sound.autoplayLooped = false
        
        self.addChild(airplaneP51Sound)
        self.addChild(airplaneFlyBySound)
        
        addSmokeTrail2()
    }

    func spawnEnemyFire() {
        enemyFire = SKSpriteNode(imageNamed: "enemyFire")
        enemyFire.setScale(0.8)
        enemyFire.position = CGPoint(x: self.position.x - 75, y: self.position.y)
        enemyFire.zPosition = 3
        
        // Body physics of player's bullets
        enemyFire.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        enemyFire.physicsBody?.affectedByGravity = false
        enemyFire.physicsBody?.collisionBitMask = PhysicsCategory.EnemyFire
        enemyFire.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Enemy | PhysicsCategory.MyBullets
        enemyFire.physicsBody?.dynamic = false
        
        self.addChild(enemyFire)
        
        // Shoot em up!
        let action = SKAction.moveToX(self.size.width - 100, duration: 1.0)
        let actionDone = SKAction.removeFromParent()
        enemyFire.runAction(SKAction.sequence([action, actionDone]))
        
        // Add sound
        planeMGunSound = SKAudioNode(fileNamed: "planeMachineGun")
        planeMGunSound.runAction(SKAction.play())
        planeMGunSound.autoplayLooped = false
        self.addChild(planeMGunSound)
        
        addGunfireToPlane2()
    }
    
    // Generate ground tank - it can't fly!! ;)
    func spawnTank() {
        tank = SKSpriteNode(imageNamed: "tank")
        let minValue = self.size.height / 6
        let maxValue = self.size.height - 40
        let spawnPoints = UInt32(maxValue - minValue)
        tank.position = CGPoint(x: self.size.width, y: CGFloat(arc4random_uniform(spawnPoints) + 200))
        tank.setScale(1.8)
        
        // Added tank physics
        tank.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        tank.physicsBody?.affectedByGravity = false
        tank.physicsBody?.collisionBitMask = PhysicsCategory.Enemy
        tank.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.MyBullets | PhysicsCategory.Enemy | PhysicsCategory.EnemyFire
        tank.physicsBody?.dynamic = true
        
        self.addChild(tank)
        
        // Add sound
        bGCannonsSound = SKAudioNode(fileNamed: "bgCannons")
        bGCannonsSound.runAction(SKAction.play())
        bGCannonsSound.autoplayLooped = false
        
        self.addChild(bGCannonsSound)
    }
    
    // Spawn enemy tank missiles
    func spawnTankMissiles() {
        missiles = SKSpriteNode(imageNamed: "missile")
        missiles.setScale(0.5)
        missiles.position = CGPoint(x: tank.position.x - 80, y: tank.position.y)
        missiles.zPosition = 4
        
        // Added missile physics
        missiles.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        missiles.physicsBody?.affectedByGravity = false
        missiles.physicsBody?.collisionBitMask = PhysicsCategory.EnemyFire
        missiles.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.MyBullets
        missiles.physicsBody?.dynamic = false
        
        self.addChild(missiles)
        
        // Add sound
        tankFiringSound = SKAudioNode(fileNamed: "tankFiring")
        tankFiringSound.runAction(SKAction.play())
        tankFiringSound.autoplayLooped = false
        
        self.addChild(tankFiringSound)
        
        // Selecting random y position for missile
        let random : CGFloat = CGFloat(arc4random_uniform(300))
        self.position = CGPointMake(self.frame.size.width + 50, random)
    }
    

    /*********************************** Emitter Functions *********************************/
    // MARK: - Emitter Functions
    
    // Add emitter of fire when bullets are fired
    func addGunfireToPlane() {
        // The plane will emit gunfire effect
        gunfire = SKEmitterNode(fileNamed: "Gunfire")
        
        //the y-position needs to be slightly in front of the plane
        gunfire.setScale(2.5)
        gunfire.zPosition = 3
        gunfire.position = CGPointMake(myPlane.position.x + 110, myPlane.position.y)
        
        // Influenced by plane's movement
        gunfire.targetNode = self.scene
        self.addChild(gunfire)
    }
    
    // Add emitter of fire when bullets are fired
    func addGunfireToPlane2() {
        // The plane will emit gunfire effect
        gunfire = SKEmitterNode(fileNamed: "Gunfire")
        
        //the y-position needs to be slightly in front of the plane
        gunfire.zPosition = 4
        gunfire.position = CGPointMake(self.position.x - 75, self.position.y)
        gunfire.setScale(1.5)
        
        // Influenced by plane's movement
        gunfire.targetNode = self.scene
        gunfire.removeFromParent()
        self.addChild(gunfire)
        
        // Add sounds to enemy planes
        planesFightSound = SKAudioNode(fileNamed: "planesFight")
        planesFightSound.runAction(SKAction.play())
        planesFightSound.autoplayLooped = false
        
        self.addChild(planesFightSound)
    }
    
    // Add emitter of exhaust smoke behind plane
    func addSmokeTrail() {
        // Create smoke trail for myPlane
        smokeTrail = SKEmitterNode(fileNamed: "SmokeTrail")
        
        //the x & y-position needs to be slightly behind the plane
        smokeTrail.zPosition = 3
        smokeTrail.position = CGPointMake(self.position.x - 200, self.position.y - 75)
        smokeTrail.setScale(3.0)
        
        // Influenced by plane's movement
        smokeTrail.targetNode = self.scene
        self.addChild(smokeTrail)
    }
    
    // Add emitter of exhaust smoke behind enemy plane
    func addSmokeTrail2() {
        // Create smoke trail for myPlane
        smokeTrail = SKEmitterNode(fileNamed: "SmokeTrail")
        
        //the x & y-position needs to be slightly behind the plane
        smokeTrail.zPosition = 3
        smokeTrail.position = CGPointMake(self.position.x + 200, self.position.y + 75)
        smokeTrail.setScale(3.0)
        
        // Influenced by plane's movement
        smokeTrail.targetNode = self.scene
        self.addChild(smokeTrail)
    }
    
    // Healthbar function for visual display
    func updateHealthBar(node: SKSpriteNode, withHealthPoints hp: Int) {
        
        let barSize = CGSize(width: HealthBarWidth, height: HealthBarHeight);
        
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
        let barWidth = (barSize.width - 1) * CGFloat(hp) / CGFloat(MaxHealth)
        let barRect = CGRect(x: 0.5, y: 0.5, width: barWidth, height: barSize.height - 1)
        CGContextFillRect(context, barRect)
        
        // extract image
        let spriteImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // set sprite texture and size
        node.texture = SKTexture(image: spriteImage)
        node.size = barSize
    }
    

}
