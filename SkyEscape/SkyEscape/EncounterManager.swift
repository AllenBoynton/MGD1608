//
//  EncounterManager.swift
//  SkyEscape
//
//  Created by Allen Boynton on 8/15/16.
//  Copyright © 2016 Full Sail. All rights reserved.
//

import SpriteKit

class EncounterManager {
    // Store your encounter file names:
    let encounterNames:[String] = [
        "EncounterStars"
    ]
    // Each encounter is an SKNode, store an array:
    var encounters:[SKNode] = []
    
    init() {
        // Loop through each encounter scene:
        for encounterFileName in encounterNames {
            // Create a new node for the encounter:
            let encounter = SKNode()
            
            // Load this scene file into a SKScene instance:
            if let encounterScene = SKScene(fileNamed:
                encounterFileName) {
                // Loop through each placeholder, spawn the
                // appropriate game object:
                for placeholder in encounterScene.children {
                    if let node: SKNode = placeholder {
                        switch node.name! {
                        case "Star":
                            let star = Star()
                            star.spawn(encounter, position:
                                node.position)
                        case "GoldCoin":
                            let coins = Coins()
                            coins.spawn(encounter, position:
                                node.position)
                            coins.turnToGold()
                        case "BronzeCoin":
                            let coins = Coins()
                            coins.spawn(encounter, position:
                                node.position)
                        default:
                            print("Name error: \(node.name)")
                        }
                    }
                }
            }
            
            // Add the populated encounter node to the array:
            encounters.append(encounter)
        }
    }
    
    // We will call this addEncountersToWorld function from
    // the GameScene to append all of the encounter nodes to the
    // world node from our GameScene:
    func addEncountersToWorld(world: SKNode) {
        for index in 0 ... encounters.count - 1 {
            // Spawn the encounters behind the action, with
            // increasing height so they do not collide:
            encounters[index].position = CGPoint(x: -2000, y:
                index * 1000)
            world.addChild(encounters[index])
        }
    }
}
