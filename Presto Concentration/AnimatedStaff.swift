//
//  AnimatedStaff.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/26/15.
//  Copyright (c) 2015 Anthony Gabriele. All rights reserved.
//

import Foundation
import SpriteKit

class AnimatedStaff: SKScene {
    let player = SKSpriteNode(imageNamed: "player")
    
    override func didMoveToView(view: SKView) {
        // 2
        backgroundColor = SKColor.whiteColor()
        // 3
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        // 4
        addChild(player)
    }
}