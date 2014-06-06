//
//  GameScene.swift
//  UberJumpSwift
//
//  Created by Song Qian on 6/5/14.
//  Copyright (c) 2014 Endlessrain Studio. All rights reserved.
//

import SpriteKit
import CoreMotion

enum CollisionCategory: UInt32 {
    case Player   = 1
    case Star     = 2
    case Platform = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var backgroundNode = SKNode()
    var midgroundNode = SKNode()
    var foregroundNode = SKNode()
    var hudNode = SKNode()
    var tapToStartNode = SKSpriteNode()
    var player = SKNode()
    var lblScore = SKLabelNode()
    var lblStars = SKLabelNode()
    
    var maxPlayerY = 0
    var gameOver = false
    
    var levelData: NSDictionary
    var endLevelY: Int
    
    var motionManager: CMMotionManager
    var xAcceleration: Double = 0.0
    
    init(size: CGSize) {
        let levelPlist = NSBundle.mainBundle().pathForResource("Level01", ofType: "plist")
        levelData = NSDictionary(contentsOfFile: levelPlist)
        endLevelY = Int(levelData["EndY"] as NSNumber)
        motionManager = CMMotionManager()
        
        super.init(size: size)
        
        // Reset
        maxPlayerY = 80
        GameState.sharedInstance.score = 0
        gameOver = false
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), {(s1, s2) -> Void in
            var acceleration = s1.acceleration
            self.xAcceleration = (acceleration.x * 0.75) + (self.xAcceleration * 0.25);
        })
    }
    
    func populateBackgroundNode() {
        for index in 0..20 {
            let imageName: String = NSString(format: "Background%02d", index+1)
            let node = SKSpriteNode(imageNamed: imageName)
            node.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            node.position = CGPoint(x: 160.0, y: Float(index)*node.size.height)
            backgroundNode.addChild(node)
        }
    }
    
    func populateMidgroundNode() {
        for i in 0..10 {
            let r = arc4random() % 2;
            let spriteName = r > 0 ? "BranchRight" : "BranchLeft"
            let branchNode = SKSpriteNode(imageNamed: spriteName)
            branchNode.position = CGPoint(x: 160.0, y: 500.0 * Float(i))
            midgroundNode.addChild(branchNode)
        }
    }
    
    func populateHUDNode() {
        let star = SKSpriteNode(imageNamed: "Star")
        star.position = CGPoint(x: 25.0, y: self.size.height-30.0)
        hudNode.addChild(star)
        
        lblStars = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblStars.fontSize = 30.0
        lblStars.fontColor = SKColor.whiteColor()
        lblStars.position = CGPoint(x: 50.0, y: self.size.height-40.0)
        lblStars.horizontalAlignmentMode = .Left
        lblStars.text = "X \(GameState.sharedInstance.stars)"
        hudNode.addChild(lblStars)
        
        lblScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblScore.fontSize = 30.0
        lblScore.fontColor = SKColor.whiteColor()
        lblScore.position = CGPoint(x: self.size.width-20.0, y: self.size.height-40.0)
        lblScore.horizontalAlignmentMode = .Right
        lblScore.text = "0"
        hudNode.addChild(lblScore)
    }
    
    func populatePlayer() {
        player.position = CGPoint(x: 160.0, y: 80.0)
        let sprite = SKSpriteNode(imageNamed: "Player")
        player.addChild(sprite)
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2.0)
        player.physicsBody.dynamic = false
        player.physicsBody.allowsRotation = false
        player.physicsBody.restitution = 1.0
        player.physicsBody.friction = 0.0
        player.physicsBody.angularDamping = 0.0
        player.physicsBody.linearDamping = 0.0
        
        player.physicsBody.usesPreciseCollisionDetection = true
        player.physicsBody.categoryBitMask = CollisionCategory.Player.toRaw()
        player.physicsBody.collisionBitMask = 0
        player.physicsBody.contactTestBitMask = CollisionCategory.Star.toRaw() | CollisionCategory.Platform.toRaw()
    }
    
    func createStarAtPosition(position: CGPoint, type: StarType) -> StarNode {
        let node = StarNode()
        node.position = position
        node.name = "NODE_STAR"
        
        node.starType = type
        let sprite = type == StarType.Special ? SKSpriteNode(imageNamed: "StarSpecial") : SKSpriteNode(imageNamed: "Star")
        node.addChild(sprite)
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2.0)
        node.physicsBody.dynamic = false
        node.physicsBody.categoryBitMask = CollisionCategory.Star.toRaw()
        node.physicsBody.collisionBitMask = 0
        
        return node
    }
    
    func createPlatformAtPosition(position: CGPoint, type: PlatformType) -> PlatformNode {
        let node = PlatformNode()
        node.position = position
        node.name = "NODE_PLATFORM"
        node.platformType = type
        
        let sprite = type == PlatformType.Break ? SKSpriteNode(imageNamed: "PlatformBreak") : SKSpriteNode(imageNamed: "Platform")
        node.addChild(sprite)
        
        node.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        node.physicsBody.dynamic = false
        node.physicsBody.categoryBitMask = CollisionCategory.Platform.toRaw()
        node.physicsBody.collisionBitMask = 0
        
        return node
    }
    
    func addPlatformsFromPlist() {
        let platforms = levelData["Platforms"] as NSDictionary
        let platformPatterns = platforms["Patterns"] as NSDictionary
        let platformPositions = platforms["Positions"] as NSArray
        for platformPosition in platformPositions {
            let position = platformPosition as NSDictionary
            let patternX = Float(position["x"] as NSNumber)
            let patternY = Float(position["y"] as NSNumber)
            let pattern = position["pattern"] as NSString
            
            let platformPattern = platformPatterns[pattern] as NSArray
            for platformPoint in platformPattern {
                let point = platformPoint as NSDictionary
                let x = Float(point["x"] as NSNumber)
                let y = Float(point["y"] as NSNumber)
                let type = PlatformType.fromRaw(Int(point["type"] as NSNumber))!
                let platformNode = createPlatformAtPosition(CGPoint(x: x+patternX, y: y+patternY), type: type)
                foregroundNode.addChild(platformNode)
            }
        }
    }
    
    func addStarsFromPlist() {
        let stars = levelData["Stars"] as NSDictionary
        let starPatterns = stars["Patterns"] as NSDictionary
        let starPositions = stars["Positions"] as NSArray
        for starPosition in starPositions {
            let position = starPosition as NSDictionary
            let patternX = Float(position["x"] as NSNumber)
            let patternY = Float(position["y"] as NSNumber)
            let pattern = position["pattern"] as NSString
            
            let starPattern = starPatterns[pattern] as NSArray
            for starPoint in starPattern {
                let point = starPoint as NSDictionary
                let x = Float(point["x"] as NSNumber)
                let y = Float(point["y"] as NSNumber)
                let type = StarType.fromRaw(Int(point["type"] as NSNumber))!
                let starNode = createStarAtPosition(CGPoint(x: x+patternX, y: y+patternY), type: type)
                foregroundNode.addChild(starNode)
            }
        }
    }
    
    func endGame() {
        gameOver = true
        
        // Save stars and high score
        GameState.sharedInstance.saveState()
        
        let endGameScene = EndGameScene(size: self.size)
        let reveal = SKTransition.fadeWithDuration(0.5)
        self.view.presentScene(endGameScene, transition: reveal)
    }
    
    override func didMoveToView(view: SKView) {
        // Add some gravity
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        physicsWorld.contactDelegate = self
        
        // Background
        populateBackgroundNode()
        addChild(backgroundNode)
        
        // Midground
        populateMidgroundNode()
        addChild(midgroundNode)
        
        // Foreground
        addChild(foregroundNode)
        
        // HUD
        populateHUDNode()
        addChild(hudNode)
        
        // Add platforms
        addPlatformsFromPlist()
        
        // Add a star
        addStarsFromPlist()
        
        // Add the player
        populatePlayer()
        foregroundNode.addChild(player)
        
        // Tap to Start
        tapToStartNode = SKSpriteNode(imageNamed: "TapToStart")
        tapToStartNode.position = CGPoint(x: 160.0, y: 180.0)
        hudNode.addChild(tapToStartNode)

    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if player.physicsBody.dynamic {
            return;
        }
        
        tapToStartNode.removeFromParent()
        player.physicsBody.dynamic = true
        player.physicsBody.applyImpulse(CGVector(dx: 0.0, dy: 20.0))
    }
    
    override func didSimulatePhysics() {
        // Set velocity based on x-axis acceleration
        player.physicsBody.velocity = CGVector(dx: Float(xAcceleration) * 400.0, dy: player.physicsBody.velocity.dy)
        
        // Check x bounds
        if player.position.x < -20.0 {
            player.position = CGPoint(x: 340.0, y: player.position.y)
        } else if player.position.x > 340.0 {
            player.position = CGPoint(x: -20.0, y: player.position.y)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        if gameOver {
            return
        }
        
        // New max height?
        if Int(player.position.y) > maxPlayerY {
            GameState.sharedInstance.score += Int(player.position.y) - maxPlayerY
            maxPlayerY = Int(player.position.y)
            lblScore.text = "\(GameState.sharedInstance.score)"
        }
        
        // Remove game objects that have passed by
        foregroundNode.enumerateChildNodesWithName("NODE_PLATFORM") {(node, stop) in
            (node as PlatformNode).checkNodeRemoval(self.player.position.y)
        }
        foregroundNode.enumerateChildNodesWithName("NODE_STAR") {(node, stop) in
            (node as StarNode).checkNodeRemoval(self.player.position.y)
        }
        
        if player.position.y > 200.0 {
            backgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - 200.0)/10.0))
            midgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - 200.0)/4.0))
            foregroundNode.position = CGPoint(x: 0.0, y: -(player.position.y - 200.0))
        }
        
        // Check if we've finisehd the level
        if Int(player.position.y) > endLevelY {
            endGame()
        }
        
        // Check if we;ve fallen too far
        if Int(player.position.y) < maxPlayerY - 400 {
            endGame()
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact!) {
        var updateHUD = false
        let other = contact.bodyA.node != player ? contact.bodyA.node : contact.bodyB.node
        updateHUD = (other as GameObjectNode).collisionWithPlayer(player)
        if updateHUD {
            lblStars.text = "X \(GameState.sharedInstance.stars)"
            lblScore.text = "\(GameState.sharedInstance.score)"
        }
    }
}
