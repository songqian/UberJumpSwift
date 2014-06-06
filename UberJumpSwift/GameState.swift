//
//  GameState.swift
//  UberJumpSwift
//
//  Created by Song Qian on 6/6/14.
//  Copyright (c) 2014 Endlessrain Studio. All rights reserved.
//

import Foundation

class GameState {
    
    var score = 0
    var highScore = 0
    var stars = 0
    
    init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let highScoreDefault = defaults.objectForKey("highScore")
        if highScoreDefault {
            highScore = Int(highScoreDefault as NSNumber)
        }
        let starsDefault = defaults.objectForKey("stars")
        if starsDefault {
            stars = Int(starsDefault as NSNumber)
        }
    }
    
    func saveState() {
        highScore = max(score, highScore)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(highScore, forKey: "highScore")
        defaults.setInteger(stars, forKey: "stars")
        defaults.synchronize()
    }
    
    class var sharedInstance: GameState {
        return GameStateSharedInstance
    }
}

let GameStateSharedInstance = GameState()
