//    // Add emitter of fire when bullets are fired
//    func addGunfireToPlane2() {
//
//        // The plane will emit gunfire effect
//        gunfire = SKEmitterNode(fileNamed: "Gunfire")
//        gunfire.particleZPosition = 1
//        gunfire.particleScale = 0.6
//
//        // Influenced by plane's movement
//        gunfire.targetNode = self.scene
//        randomEnemy.addChild(gunfire)
//
//        // Add sounds to enemy planes
//        planesFightSound = SKAudioNode(fileNamed: "planesFight")
//        planesFightSound.runAction(SKAction.play())
//        planesFightSound.autoplayLooped = false
//
////        self.addChild(planesFightSound)
//    }
//
