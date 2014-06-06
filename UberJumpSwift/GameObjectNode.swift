//
//  GameObjectNode.swift
//  UberJumpSwift
//
//  Created by Song Qian on 6/5/14.
//  Copyright (c) 2014 Endlessrain Studio. All rights reserved.
//

import SpriteKit

class GameObjectNode: SKNode {

    func collisionWithPlayer(player: SKNode) -> Bool {
        return false
    }
    
    func checkNodeRemoval(playerY: CGFloat) {
        if playerY > self.position.y + 300.0 {
            self.removeFromParent()
        }
    }
}

enum StarType: Int {
    case Normal = 0
    case Special
}

class StarNode: GameObjectNode {
    
    var starType: StarType
    var starSound: SKAction
    
    init() {
        starType = .Normal
        starSound = SKAction.playSoundFileNamed("StarPing.wav", waitForCompletion: false)
        super.init()
    }
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        player.physicsBody.velocity = CGVector(dx: player.physicsBody.velocity.dx, dy: 400.0)
        parent.runAction(starSound)
        self.removeFromParent()
        // Award stars
        GameState.sharedInstance.stars += starType == .Normal ? 1: 5
        // Award points
        GameState.sharedInstance.score += starType == .Normal ? 20 : 100
        return true;
    }
}

enum PlatformType: Int {
    case Normal = 0
    case Break
}

class PlatformNode: GameObjectNode {
    
    var platformType = PlatformType.Normal
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        // Only bounce the player if he's falling
        if player.physicsBody.velocity.dy < 0 {
            player.physicsBody.velocity = CGVector(dx: player.physicsBody.velocity.dx, dy: 250.0)
            
            // Remove if it is a Break type platform
            if platformType == .Break {
                self.removeFromParent()
            }
        }
        
        // No stars for platforms
        return false;
    }
}