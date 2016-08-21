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



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
  
    /********************************** didMoveToView Function **********************************/
    // MARK: - didMoveToView
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
    
    }
    
    
    /********************************* touchesBegan Function **************************************/
    // MARK: - touchesBegan
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        if gameStarted == false {
            
            gameStarted = true
            
            
            touchLocation = touches.first!.locationInNode(self)
            
            for touch: AnyObject in touches {
                let location = (touch as! UITouch).locationInNode(self)
                
                // Sets the physics delegate and physics body
                self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
                self.physicsWorld.contactDelegate = self // Physics delegate set
                
                // Allows user to move plane upon begin touch
                myPlane.position.y = location.y // Allows a tap to touch on the y axis
                myPlane.position.x = location.x // Allows a tap to touch on the x axis
                
            }
        }
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

}