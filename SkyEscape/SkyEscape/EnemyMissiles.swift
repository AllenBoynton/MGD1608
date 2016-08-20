//// Spawn enemy tank missiles
//func spawnTankMissiles() {
//
//    // Spawning an enemy tank's anti-aircraft missiles
//    missiles = SKSpriteNode(imageNamed: "missile")
//    missiles.setScale(0.5)
//    missiles.zPosition = -9
//
//    missiles.position = CGPoint(x: tank.position.x, y: tank.position.y)
//
//    // Added missile physics
//    missiles.physicsBody = SKPhysicsBody(rectangleOfSize: missiles.size)
//    missiles.physicsBody?.affectedByGravity = false
//    missiles.physicsBody?.categoryBitMask = PhysicsCategory.Missiles128
//    missiles.physicsBody?.contactTestBitMask = PhysicsCategory.Player8 | PhysicsCategory.MyBullets2
//    missiles.physicsBody?.collisionBitMask = 128
//    missiles.physicsBody?.dynamic = false
//
//    // Shoot em up!
//    let action = SKAction.moveToY(self.size.height + 80, duration: 3.0)
//    let actionDone = SKAction.removeFromParent()
//    missiles.runAction(SKAction.sequence([action, actionDone]))
//
//    self.addChild(missiles) // Generate tank missile
//
//    // Add sound
//    tankFiringSound = SKAudioNode(fileNamed: "tankFiring")
//    tankFiringSound.runAction(SKAction.play())
//    tankFiringSound.autoplayLooped = false

//        self.addChild(tankFiringSound)