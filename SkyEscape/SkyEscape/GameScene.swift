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


class GameScene: SKScene, SKPhysicsContactDelegate, UIAccelerometerDelegate {
    
    let world = SKNode()
    let ground = Ground()
    let player = Player()
    let bullets = Bullets()
    let bombs = Bombs()
    let star = Star()
    let bronzeCoin = Coins()
    let goldCoin = Coins()
    let enemy = Enemy()
    let enemyFire = EnemyFire()
    let tank = Tank()
    let enemyMissiles = EnemyMissiles()
    
    var screenCenterY = CGFloat()
    var playerProgress = CGFloat()
    let initialPlanePosition = CGPoint(x: 150, y: 250)
    
    // Location for touch screen
    var touchLocation: CGPoint = CGPointZero
//    var motionManager = CMMotionManager()
    
    // The scroll version of the nodes will become a scrolling, repeating backround
    // Main background
    var myBackground = SKSpriteNode()
    
    // Mid background
    var midground1 = SKSpriteNode()
    var midground2 = SKSpriteNode()
    var mtHeight = CGFloat(200)
    
    // Foreground
    var foreground = SKSpriteNode()
    
    // Sky nodes
    var badCloud = SKSpriteNode()
    var myBomber = SKSpriteNode()
    
    // Timers for spawn / interval / delays
    var timer = NSTimer()
    var enemyTimer = NSTimer()
    var enemyShoots = NSTimer()
    var enemyTankTimer = NSTimer()
    var enemyTankShoots = NSTimer()
    
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
    var nextTime = NSDate()
    var healthLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    
    
    /********************************* didMoveToView Function *********************************/
    // MARK: - didMoveToView
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        // Sets the physics delegate and physics body
        physicsWorld.contactDelegate = self // Physics delegate set
        
        // Add the world node as a child of the scene:
        self.addChild(world)
        
        // Store the vertical center of the screen:
        screenCenterY = self.size.height / 2
        
        /********************************* Adding Scroll Background *********************************/
        // MARK: - Scroll Background
        
        // Adding scrolling Main Background
        myBackground = SKSpriteNode(imageNamed: "cartoonCloudsBGLS")
        createBackground()
        
        // Adding a midground
        midground1 = SKSpriteNode(imageNamed: "mountain")
        midground2 = SKSpriteNode(imageNamed: "mountain")
        createMidground()
        
//        foreground = SKSpriteNode(imageNamed: "lonelytree")
//        createForeground()
        
        // Adding the moving foreground
        // Sizing and placing the ground based on the screen size.
        let groundPosition = CGPoint(x: -self.size.width, y: 30)
        
        // Hight is determined. This will provide plenty of ground for movement
        let groundSize = CGSize(width: self.size.width * 3, height: 0)
        
        // Spawn the ground!
        ground.spawn(world, position: groundPosition, size: groundSize)
        
        
    /********************************* Spawning Nodes *********************************/
    // MARK: - Spawning
        
        // Adding our player's plane to the scene
        player.spawn(world, position: initialPlanePosition)
        
        // The powerup star:
        star.spawn(world, position: CGPoint(x: 250, y: 250))
        
        // Adding the bronze coin - value = 1
        bronzeCoin.spawn(world, position: CGPoint(x: 490, y: 250))
        
        // Adding the gold coin - value = 5
        goldCoin.spawn(world, position: CGPoint(x: 460, y: 250))
        goldCoin.turnToGold()
        
        // Spawning random points for air enemies
        let minValue = Int(self.size.height / 2)
        let maxValue = Int(self.size.height - 100)
        let spawnPoints = UInt32(maxValue - minValue)
        enemy.spawn(world, position: CGPoint(x: self.size.width, y: CGFloat(arc4random_uniform(spawnPoints) + 200)))
        
        // Spawning bullets for the enemy planes
        enemyFire.spawn(world, position: CGPointMake(enemy.position.x + 75, enemy.position.y))
        addGunfireToPlane2()
        
        // Spawning the tank
        let minTank = Int(self.size.width / 9)
        let maxTank = Int(self.size.width - 20)
        let tankSpawnPoint = UInt32(maxTank - minTank)
        tank.spawn(world, position: CGPoint(x: CGFloat(arc4random_uniform(tankSpawnPoint) + 40), y: self.size.height))
        
        // Spawning the missiles for enemy tank
        enemyMissiles.spawn(world, position: CGPointMake(tank.position.x - 80, tank.position.y))
        
        // Initilize values and labels
//        initializeValues()
    
        
    /********************************* Spawn Timers *********************************/
    // MARK: - Spawn Timers
        
        // Spawning bullets timer call
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(Bullets.spawn), userInfo: nil, repeats: false)
        
        // Spawning enemies timer call
        enemyTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(Enemy.spawn), userInfo: nil, repeats: true)
        
        // Spawning enemy fire timer call
        enemyShoots = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(EnemyFire.spawn), userInfo: nil, repeats: false)
        
        // Set enemy tank spawn intervals
        enemyTankTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(Tank.spawn), userInfo: nil, repeats: true)
        
        // Spawning tank missile timer call
        enemyTankShoots = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(EnemyMissiles.spawn), userInfo: nil, repeats: false)
        
        
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
        bgMusic.autoplayLooped = false
        
        biplaneFlyingSound = SKAudioNode(fileNamed: "biplaneFlying")
        biplaneFlyingSound.runAction(SKAction.play())
        biplaneFlyingSound.autoplayLooped = false
        
//        addChild(bgMusic)
        addChild(biplaneFlyingSound)
        
        // Update core motion to let it know where the plane is
//        self.motionManager.startAccelerometerUpdates()
    }
    
    
    /********************************** Simulating Physics ***************************************/
    // MARK: - Spawning
    
    override func didSimulatePhysics() {
        let worldXPos = -(player.position.x * world.xScale - (self.size.width / 2))
        let worldYPos = -(player.position.y * world.yScale - (self.size.height / 2))
        world.position = CGPoint(x: worldXPos, y: worldYPos)
    }
    
//    override func didSimulatePhysics() {
//        var worldYPos: CGFloat = 0
//        
//        // Zoom the world as the plane flies higher
//        if (player.position.y > screenCenterY) {
//            let percentOfMaxHeight = (player.position.y - screenCenterY) / (/*player.maxHeight*/ 200 - screenCenterY)
//            let scaleSubtraction = (percentOfMaxHeight > 1 ? 1 : percentOfMaxHeight) * 0.6
//            let newScale = 1 - scaleSubtraction
//            world.yScale = newScale
//            world.xScale = newScale
//            
//            // The world scene adjusts depending on the height of our plane
//            worldYPos = -(player.position.y * world.yScale -
//                (self.size.height / 2))
//        }
//        
//        let worldXPos = -(player.position.x * world.xScale -
//            (self.size.width / 3))
//        
//        // Move the world for our adjustment of camera view
//        world.position = CGPoint(x: worldXPos, y: worldYPos)
//    }
    
    
    /********************************* Update Function *********************************/
    // MARK: - Update Function
    
    override func update(currentTime: NSTimeInterval) {
//        player.update()
        
        // Unwrap the accelerometer data optional:
//        if let accelData = self.motionManager.accelerometerData {
//            var forceAmount:CGFloat
//            var movement = CGVector()
//            
//            // Based on the orientation of the device, the tilt number from
//            // Core Motion will indicate opposite user desire for motion
//            // The UIApplication class exposes an enum that allows us to
//            // pull the current orientation. We will use this opportunity
//            // to explore Swift's switch syntax and assign the correct
//            // force for the current orientation:
//            switch UIApplication.sharedApplication().statusBarOrientation {
//            case .LandscapeLeft:
//                forceAmount = 80
//            case .LandscapeRight:
//                forceAmount = -80
//            default:
//                forceAmount = 0
//            }
//            
//            // If the device is tilted more than 15% towards complete vertical,
//            // then create a vector, applying the force horizontally
//            if accelData.acceleration.y > 0.15 {
//                movement.dx = forceAmount
//            }
//            
//            // Core Motion values are always in terms of portrait orientation.
//            // Since we are in landscape, we use the y-values for our x-axis.
//            else if accelData.acceleration.y < -0.15 {
//                movement.dx = -forceAmount
//            }
//            
//            // Apply the force we have created:
//            player.physicsBody?.applyForce(movement)
//        }
        
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
        
        //        checkIfPlaneGetsAcross()
        //        checkIfGameIsOver()
    }
    
    
    /********************************* touchesBegan Function *********************************/
    // MARK: - touchesBegan
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        touchLocation = touches.first!.locationInNode(self)
        
        for touch in touches {
            // Find the location of the touch:
            let location = touch.locationInNode(self)
            // Locate the node at this location:
            let nodeTouched = nodeAtPoint(location)
            // Attempt to downcast the node to the GameSprite protocol
            if let gameSprite = nodeTouched as? GameSprite {
                // If this node adheres to GameSprite, call onTap:
                gameSprite.onTap()
            }

            /* Allows to tap on screen and plane will present
                at that axis and shoot at point touched */
            player.position.y = location.y // Allows a tap to touch on the y axis
            player.position.x = location.x // Allows a tap to touch on the x axis
            
            // Spawning bullets for our player
            bullets.spawn(world, position: CGPointMake(player.position.x + 75, player.position.y))
            addGunfireToPlane()
        }
    }
    
    
    /********************************* touchesMoved Function *********************************/
    // MARK: - touchesMoved
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
        
        for touch: AnyObject in touches {
            let location = (touch as! UITouch).locationInNode(self)
            
            /* Allows to drag on screen and plane will follow
            that axis and shoot at point when released */
            player.position.y = location.y // Allows a tap to touch on the y axis
            player.position.x = location.x
        }
    }
    
    
    /********************************* touchesEnded Function *********************************/
    // MARK: - touchesEnded
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Each node will collide with the equalled item due to bit mask
        bombs.spawn(world, position: CGPointMake(player.position.x, player.position.y - 100))
    }
    // Want to use use a double tap or long press to drop bomb
    
    
    /************************************ didBeginContact ************************************/
    // MARK: - didBeginContact
    
    func didBeginContact(contact: SKPhysicsContact) {
        print("PLANE HAS CONTACT")
        // Establish that badCloud has a bit mask
        /* Assigning bit collision for the cloud now -
         it does not have a block of code*/
        badCloud.physicsBody?.collisionBitMask = PhysicsCategory.Cloud
        
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB
        
        if ((firstBody.categoryBitMask == PhysicsCategory.Enemy) && (secondBody.categoryBitMask == PhysicsCategory.MyBullets) ||
            (firstBody.categoryBitMask == PhysicsCategory.MyBullets) && (secondBody.categoryBitMask == PhysicsCategory.Enemy)) {
                didBulletsHitEnemy(firstBody.node as! SKSpriteNode, MyBullets: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Enemy) && (secondBody.categoryBitMask == PhysicsCategory.Player) ||
            (firstBody.categoryBitMask == PhysicsCategory.Player) && (secondBody.categoryBitMask == PhysicsCategory.Enemy)) {
                self.didEnemyHitPlayer(firstBody.node as! SKSpriteNode, Player: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.EnemyFire) && (secondBody.categoryBitMask == PhysicsCategory.Player) ||
            (firstBody.categoryBitMask == PhysicsCategory.Player) && (secondBody.categoryBitMask == PhysicsCategory.EnemyFire)) {
            self.didEnemyFireHitPlayer(firstBody.node as! SKSpriteNode, Player: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.MyBullets) && (secondBody.categoryBitMask == PhysicsCategory.StarMask) ||
            (firstBody.categoryBitMask == PhysicsCategory.StarMask) && (secondBody.categoryBitMask == PhysicsCategory.MyBullets)) {
                self.didBulletsHitStar(firstBody.node as! SKSpriteNode, StarMask: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Player) && (secondBody.categoryBitMask == PhysicsCategory.StarMask) ||
            (firstBody.categoryBitMask == PhysicsCategory.StarMask) && (secondBody.categoryBitMask == PhysicsCategory.Player)) {
                self.didPlayerHitStar(firstBody.node as! SKSpriteNode, StarMask: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.MyBullets) && (secondBody.categoryBitMask == PhysicsCategory.Cloud) ||
            (firstBody.categoryBitMask == PhysicsCategory.Cloud) && (secondBody.categoryBitMask == PhysicsCategory.MyBullets)) {
                self.didBulletsHitCloud(firstBody.node as! SKSpriteNode, Cloud: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Player) && (secondBody.categoryBitMask == PhysicsCategory.Ground) ||
            (firstBody.categoryBitMask == PhysicsCategory.Ground) && (secondBody.categoryBitMask == PhysicsCategory.Player)) {
                self.didPlayerHitGround(firstBody.node as! SKSpriteNode, Ground: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.MyBullets) && (secondBody.categoryBitMask == PhysicsCategory.Ground) ||
            (firstBody.categoryBitMask == PhysicsCategory.Ground) && (secondBody.categoryBitMask == PhysicsCategory.MyBullets)) {
            self.didBulletsHitGround(firstBody.node as! SKSpriteNode, Ground: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.MyBullets) && (secondBody.categoryBitMask == PhysicsCategory.Coins) ||
            (firstBody.categoryBitMask == PhysicsCategory.Coins) && (secondBody.categoryBitMask == PhysicsCategory.MyBullets)) {
            self.didBulletsHitCoins(firstBody.node as! SKSpriteNode, Coins: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Player) && (secondBody.categoryBitMask == PhysicsCategory.Coins) ||
            (firstBody.categoryBitMask == PhysicsCategory.Coins) && (secondBody.categoryBitMask == PhysicsCategory.Player)) {
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
//    func createForeground() {
//        let foreground = SKTexture(imageNamed: "lonelytree")
//        
//        for i in 0...1 {
//            let ground = SKSpriteNode(texture: foreground)
//            ground.zPosition = 30
//            ground.position = CGPoint(x: (foreground.size().width / 2 + (foreground.size().width * CGFloat(i))), y: foreground.size().height / 2)
//            
//            // Create physics body
//            ground.physicsBody = SKPhysicsBody(edgeLoopFromRect: ground.frame)
//            ground.physicsBody?.affectedByGravity = false
//            ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
//            ground.physicsBody?.contactTestBitMask = PhysicsCategory.Player
//            ground.physicsBody?.dynamic = false
//            
//            self.addChild(ground)
//            
//            let moveLeft = SKAction.moveByX(-foreground.size().width, y: 0, duration: 10)
//            let moveReset = SKAction.moveByX(foreground.size().width, y: 0, duration: 0)
//            let moveLoop = SKAction.sequence([moveLeft, moveReset])
//            let moveForever = SKAction.repeatActionForever(moveLoop)
//            
//            ground.shadowCastBitMask = 1
//            
//            ground.runAction(moveForever)
//        }
//    }
    
        
    /*********************************** Emitter Functions *********************************/
    // MARK: - Spawn Functions
    
    // Add emitter of fire when bullets are fired
    func addGunfireToPlane() {
        // The plane will emit gunfire effect
        gunfire = SKEmitterNode(fileNamed: "Gunfire")
        
        //the y-position needs to be slightly in front of the plane
        gunfire.setScale(2.5)
        gunfire.zPosition = 3
        gunfire.position = CGPointMake(player.position.x + 110, player.position.y)
        
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
        gunfire.position = CGPointMake(enemy.position.x - 75, enemy.position.y)
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
}
