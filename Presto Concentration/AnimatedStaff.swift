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
    let staff = SKSpriteNode(imageNamed: "Music-Staff")
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
        staff.size = CGSize(width: size.width, height: size.height/4)
        staff.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(staff)
    }
    
    func notesPressed(notes:Set<Note>){
        println("GOD HELP US");
    }
    
}