//    // Spawning bombs for player's plane
//    func spawnBombs() {
//
//        // Setup bomb node
//        bombs = SKSpriteNode(imageNamed: "bomb1")
////        bombs.setScale(0.2)
//        bombs.zPosition = 5
//
//        bombs.position = CGPointMake(myPlane.position.x, myPlane.position.y)
//
//        // Body physics of player's bullets
//        bombs.physicsBody = SKPhysicsBody(rectangleOfSize: bombs.size)
//        bombs.physicsBody?.affectedByGravity = false
//        bombs.physicsBody?.categoryBitMask = PhysicsCategory.MyBombs4
//        bombs.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy16 | PhysicsCategory.StarMask512 | PhysicsCategory.Cloud256 | PhysicsCategory.Ground1
//        bombs.physicsBody?.collisionBitMask = 4
//        bombs.physicsBody?.usesPreciseCollisionDetection = true
//        bombs.physicsBody?.dynamic = false
//
//        // Drop em!
//        let action = SKAction.moveToY(-80, duration: 2.0)
//        let actionDone = SKAction.removeFromParent()
//        bombs.runAction(SKAction.sequence([action, actionDone]))
//
//        self.addChild(bombs)
//
//        // Adding sound
//        bombSound = SKAudioNode(fileNamed: "bomb")
//        bombSound.runAction(SKAction.play())
//        bombSound.autoplayLooped = false
//
////        self.addChild(bombSound)
//
//        bombs.hidden = true
//    }
//

