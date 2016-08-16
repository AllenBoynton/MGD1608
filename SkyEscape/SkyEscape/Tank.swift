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

// TOUCHESBEGAN - AT BOTTOM
// Counts number of enemies
//            if let theName = self.nodeAtPoint(location).name {
//                if theName == "Enemy" {
//                    self.removeChildrenInArray([self.nodeAtPoint(location)])
//                    currentNumberOfEnemies-=1
//                    score+=1
//                }
//            }
//            if (gameOver == true){ // If goal is hit - game is completed
//                initializeValues()
//            }
// Starting and stopping background sound
//        bgMusic.runAction(SKAction.pause())


// WITHIN UPDATE AT BOTTOM
// Planes movement actions by accelerometer ---------------------> Future use!
//        let action1 = SKAction.moveToX(destinationX, duration: 1.0)
//        let action2 = SKAction.moveToY(destinationY, duration: 1.0)
//        let moveAction = SKAction.sequence([action1, action2])
//        MyPlane.runAction(moveAction)

// Adding to gameplay health attributes
//        healthLabel.text = "Health: \(health)"
//
//        // Changes health label red if too low
//        if(health <= 3) {
//            healthLabel.fontColor = SKColor.redColor()
//        }
//
//        now = NSDate()
//        if (currentNumberOfEnemies < maxNumberOfEnemies &&
//            now.timeIntervalSince1970 > nextTime.timeIntervalSince1970 &&
//            health > 0) {
//
//            nextTime = now.dateByAddingTimeInterval(NSTimeInterval(timeBetweenEnemies))
//            enemySpeed = enemySpeed / moveFactor
//            timeBetweenEnemies = timeBetweenEnemies/moveFactor
//        }
//


// INITIALIZATION VALUES - GOES NEAR BOTTOM AFTER LAST OBJECT SPAWNED
// Sets the initial values for our variables
//    func initializeValues(){
//        self.removeAllChildren()
//
//        score = 0
//        gameOver = false
//        currentNumberOfEnemies = 0
//        timeBetweenEnemies = 1.0
//        enemySpeed = 5.0
//        health = 10
//        nextTime = NSDate()
//        now = NSDate()
//
//        healthLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
//        healthLabel.text = "Health: \(health)"
//        healthLabel.fontSize = 40
//        healthLabel.fontColor = SKColor.blackColor()
//        healthLabel.position = CGPoint(x: frame.minX + 100, y: frame.minY + 40)
//
//        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
//        scoreLabel.text = "Score: \(score)"
//        scoreLabel.fontSize = 40
//        scoreLabel.fontColor = SKColor.blackColor()
//        scoreLabel.position = CGPoint(x: frame.maxX - 100, y: frame.maxY - 40)
//        scoreLabel.horizontalAlignmentMode = .Right
//
//        gameOverLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
//        gameOverLabel.text = "GAME OVER"
//        gameOverLabel.fontSize = 80
//        gameOverLabel.fontColor = SKColor.blackColor()
//        gameOverLabel.position = CGPoint(x: CGRectGetMinX(self.frame)/2, y: (CGRectGetMinY(self.frame)/2))
//
//        self.addChild(healthLabel)
//        self.addChild(scoreLabel)
//        self.addChild(gameOverLabel)
//    }

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
//    func checkIfPlaneGetsAcross(){
//        for child in self.children {
//            if(child.position.x == 0){
//                self.removeChildrenInArray([child])
//                currentNumberOfEnemies-=1
//                health -= 1
//            }
//        }
//    }

//    // Displays the game over screen
//    func showGameOverScreen(){
//        gameOverLabel = SKLabelNode(fontNamed: "System")
//        gameOverLabel.text = "Game Over! Score: \(score)"
//        gameOverLabel.fontColor = SKColor.redColor()
//        gameOverLabel.fontSize = 65
//        gameOverLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame));
//        self.addChild(gameOverLabel)
//    }

