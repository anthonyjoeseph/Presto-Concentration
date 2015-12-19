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
    private var ledgerLineSpace:CGFloat = 0.0
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
        
        staff.size = CGSize(width: size.width, height: size.height/4)
        staff.position = CGPoint(x: size.width/2, y: size.height/2)
        staff.zPosition = 0.0
        
        let noteZone = SKSpriteNode(imageNamed: "NoteZone")
        noteZone.size = CGSize(width: size.width/6, height: size.height)
        noteZone.position = CGPoint(x: size.width/2, y: size.height/2)
        noteZone.zPosition = 2.0
        
        ledgerLineSpace = staff.size.height * 0.245
        
        addChild(staff)
        addChild(noteZone)
        
    }
    
    func addNote(note:Note, reachCenterBy:NSTimeInterval){
        
        let ivoryFloorNote:Note
        if !note.isIvory {
            ivoryFloorNote = Note(absoluteNote: note.absoluteNote-1);
        }else{
            ivoryFloorNote = note
        }
        let noteSprite:SKSpriteNode = NoteSprite(imageNamed:"wholeNote")
        let oldNoteHeight = noteSprite.size.width
        noteSprite.xScale = ledgerLineSpace/oldNoteHeight
        noteSprite.yScale = noteSprite.xScale
        noteSprite.zPosition = 1.0
        
        let bFourPosition = size.height/2
        let bFour:Note = Note(absoluteNote: 50)
        
        let ivoryDistance:CGFloat = CGFloat(bFour.ivoryDistance(ivoryFloorNote))
        let noteSpriteY:CGFloat = bFourPosition + ivoryDistance * (ledgerLineSpace/2)
        
        noteSprite.position = CGPoint(x:size.width+(noteSprite.size.width/2), y:noteSpriteY)
        
        let actionMove = SKAction.moveTo(CGPoint(x: -noteSprite.size.width/2, y: noteSprite.position.y), duration: reachCenterBy*2)
        let actionMoveDone = SKAction.removeFromParent()
        noteSprite.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        addChild(noteSprite)
    }
    
    func notesPressed(notes:Set<Note>){
        for note:Note in notes{
            addNote(note, reachCenterBy: 9.5)
        }
    }
    
}