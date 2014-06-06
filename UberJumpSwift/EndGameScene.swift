//
//  EndGameScene.swift
//  UberJumpSwift
//
//  Created by Song Qian on 6/6/14.
//  Copyright (c) 2014 Endlessrain Studio. All rights reserved.
//

import SpriteKit

class EndGameScene: SKScene {
    
    init(size: CGSize) {
        super.init(size: size)
        
        // Stars
        let star = SKSpriteNode(imageNamed: "Star")
        star.position = CGPoint(x: 25.0, y: self.size.height-30.0)
        self.addChild(star)
        let lblStars = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblStars.fontSize = 30.0
        lblStars.fontColor = SKColor.whiteColor()
        lblStars.position = CGPoint(x: 50.0, y: self.size.height-40.0)
        lblStars.horizontalAlignmentMode = .Left
        lblStars.text = "X \(GameState.sharedInstance.stars)"
        self.addChild(lblStars)
        
        // Score
        let lblScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblScore.fontSize = 60.0
        lblScore.fontColor = SKColor.whiteColor()
        lblScore.position = CGPoint(x: 160.0, y: 300.0)
        lblScore.horizontalAlignmentMode = .Center
        lblScore.text = "\(GameState.sharedInstance.score)"
        self.addChild(lblScore)
        
        // High Score
        let lblHighScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblHighScore.fontSize = 30.0
        lblHighScore.fontColor = SKColor.whiteColor()
        lblHighScore.position = CGPoint(x: 160.0, y: 150.0)
        lblHighScore.horizontalAlignmentMode = .Center
        lblHighScore.text = "High Score: \(GameState.sharedInstance.score)"
        self.addChild(lblHighScore)
        
        // Try again
        let lblTryAgain = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblTryAgain.fontSize = 30.0
        lblTryAgain.fontColor = SKColor.whiteColor()
        lblTryAgain.position = CGPoint(x: 160.0, y: 50.0)
        lblTryAgain.horizontalAlignmentMode = .Center
        lblTryAgain.text = "Tap To Try Again"
        self.addChild(lblTryAgain)
    }
 
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        // Transition back to the game
        let gameScene = GameScene(size: self.size)
        let reveal = SKTransition.fadeWithDuration(0.5)
        self.view.presentScene(gameScene, transition: reveal)
    }
}
