// CONTENT BELOW IS FUTURE CODE FOR THE PROJECT. THIS IS MY TEMP STORAGE AREA!

// WITHIN DIDMOVETOVIEW
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

            
// WITHIN UPDATE AT BOTTOM
// Planes movement actions by accelerometer ---------------------> Future use!
//        let action1 = SKAction.moveToX(destinationX, duration: 1.0)
//        let action2 = SKAction.moveToY(destinationY, duration: 1.0)
//        let moveAction = SKAction.sequence([action1, action2])
//        MyPlane.runAction(moveAction)

        
// Spawn ground tank - it can't fly!! ;)
//func spawnTank() {
//    
//    // Spawning an enemy tank
//    tank = SKSpriteNode(imageNamed: "tank")
//    tank.setScale(0.2)
//    tank.zPosition = 2
//    
//    tank.position = CGPoint(x: self.size.width, y: self.size.height + 150)
//    
//    // Added tank physics
//    tank.physicsBody = SKPhysicsBody(rectangleOfSize: tank.size)
//    tank.physicsBody?.affectedByGravity = false
//    tank.physicsBody?.categoryBitMask = PhysicsCategory.Tank32
//    tank.physicsBody?.contactTestBitMask = PhysicsCategory.Player8 | PhysicsCategory.MyBullets2 | PhysicsCategory.Enemy16 | PhysicsCategory.EnemyFire64
//    tank.physicsBody?.collisionBitMask = 32
//    tank.physicsBody?.dynamic = true
//    
//    // Shoot em up!
//    let action = SKAction.moveToX(-200, duration: 8.0)
//    let actionDone = SKAction.removeFromParent()
//    tank.runAction(SKAction.sequence([action, actionDone]))
//    
//    self.addChild(tank) // Generate enemy tank
//    
//    // Add sound
//    tankSound = SKAudioNode(fileNamed: "tank")
//    tankSound.runAction(SKAction.play())
//    tankSound.autoplayLooped = false
//    
//    self.addChild(tankSound)
//}
//
//}


    