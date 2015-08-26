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
        staff.zPosition = 0.0
        
        let noteZone = SKSpriteNode(imageNamed: "NoteZone")
        noteZone.size = CGSize(width: size.width/6, height: size.height)
        noteZone.position = CGPoint(x: size.width/2, y: size.height/2)
        noteZone.zPosition = 1.0
        
        addChild(staff)
        addChild(noteZone)
        
    }
    
    func addNote(note:Note, reachCenterBy:NSTimeInterval){
        let noteSprite:SKSpriteNode = NoteSprite(imageNamed:"wholeNote")
        let oldNoteHeight = noteSprite.size.width
        let newNoteHeight = staff.size.height/4
        noteSprite.xScale = newNoteHeight/oldNoteHeight
        noteSprite.yScale = noteSprite.xScale
        noteSprite.zPosition = 2.0
        
        /*let staffPosition:Int
        
        switch(note.noteLetter){
        case NoteLetter.A:
            staffPosition = 0
        case NoteLetter.B:
            staffPosition = 1
        case NoteLetter.C:
            staffPosition = 2
        case NoteLetter.D:
            staffPosition = 3
        case NoteLetter.E:
            staffPosition = 4
        case NoteLetter.F:
            staffPosition = 5
        case NoteLetter.G:
            staffPosition = 6
        default:
            staffPosition = 0
        }
        
        let noteHeight = noteSprite.size.height
        let middleCPosition = size.height/2*/
        
        noteSprite.position = CGPoint(x:size.width+(noteSprite.size.width/2), y:size.height/2)
        
        let actionMove = SKAction.moveTo(CGPoint(x: -noteSprite.size.width/2, y: noteSprite.position.y), duration: reachCenterBy*2)
        let actionMoveDone = SKAction.removeFromParent()
        noteSprite.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        addChild(noteSprite)
    }
    
    func notesPressed(notes:Set<Note>){
        for note:Note in notes{
            addNote(note, reachCenterBy: 1.0)
        }
    }
    
}