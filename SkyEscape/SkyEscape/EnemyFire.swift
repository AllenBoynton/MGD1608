//
//  EnemyFire.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/11/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

// A new class, inheriting from SKSpriteNode and
// adhering to the GameSprite protocol

class EnemyFire: SKSpriteNode {
    
    let gameScene = GameScene()
    
    // Spawn enemyfire
    var textureAtlas: SKTextureAtlas =
        SKTextureAtlas(named:"goods.atlas")
    
    // Implement onTap to adhere to the protocol:
    func onTap() {}
}
