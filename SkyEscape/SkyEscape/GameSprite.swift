//
//  GameSprite.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/13/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

protocol GameSprite {
    var textureAtlas: SKTextureAtlas { get set }
    func spawn(parentNode: SKNode, position: CGPoint, size: CGSize)
    func onTap()
}
