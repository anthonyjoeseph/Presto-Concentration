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
    
    static let clefXPos:CGFloat = 100
    static let keySigXPos:CGFloat = 180
    static let tempoXPos:CGFloat = 40
    
    let staffNode = SKSpriteNode(imageNamed: "Music-Staff")
    private let noteZoneUnpressedTexture = SKTexture(imageNamed: "NoteZone")
    private let noteZonePressedTexture = SKTexture(imageNamed: "NoteZonePressed")
    let noteZone:SKSpriteNode
    let scoreNode:SKLabelNode = SKLabelNode(fontNamed: "Gotham-Bold")
    private var ledgerLineSpace:CGFloat = 0.0
    private var currentKeySignatureSprite:KeySignatureSprite? = nil
    private var currentClefSprite:SKSpriteNode? = nil
    private var currentTempoMarkingSprite:SKSpriteNode? = nil
    
    required init?(coder aDecoder: NSCoder) {
        self.noteZone = SKSpriteNode(texture: self.noteZoneUnpressedTexture)
        super.init()
    }
    
    override init(size: CGSize) {
        self.noteZone = SKSpriteNode(texture: self.noteZoneUnpressedTexture)
        super.init(size: size)
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
        
        staffNode.size = CGSize(width: size.width, height: size.height/4)
        staffNode.position = CGPoint(x: size.width/2, y: size.height/2)
        staffNode.zPosition = 0.0
        
        noteZone.position = CGPoint(x: size.width/2, y: size.height/2)
        noteZone.zPosition = 2.0
        noteZone.anchorPoint = CGPoint(x: 0.5, y: 0.52)
        let currentNoteZoneHeight = noteZoneUnpressedTexture.size().height
        let desiredNoteZoneHeight = self.size.height * 0.95
        let heightScale = desiredNoteZoneHeight/currentNoteZoneHeight
        noteZone.xScale = heightScale
        noteZone.yScale = heightScale
        
        scoreNode.fontColor = UIColor.blackColor()
        scoreNode.fontSize = 50
        scoreNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        scoreNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        scoreNode.position = CGPoint(x: self.size.width - scoreNode.frame.width , y: 100 + ((staffNode.size.height/2)+staffNode.position.y))
        
        self.ledgerLineSpace = staffNode.size.height * 0.245
        
        addChild(staffNode)
        addChild(noteZone)
        addChild(scoreNode)
    }
    
    func pressNoteZone(){
        self.noteZone.texture = self.noteZonePressedTexture
    }
    
    func releaseNoteZone(){
        self.noteZone.texture = self.noteZoneUnpressedTexture
    }
    
    func animateNoteSprite(noteSprite:NoteSprite, pixelsPerSecond:Double, callbackFunc:(Void) -> Void){
        noteSprite.addLedgerLines(ledgerLineSpace)
        
        let oldNoteHeight = noteSprite.size.width
        noteSprite.xScale = self.ledgerLineSpace/oldNoteHeight
        noteSprite.yScale = noteSprite.xScale
        noteSprite.zPosition = 1.0
        
        let middlePosition = self.size.height/2
        let noteSpriteY:CGFloat = middlePosition + CGFloat(noteSprite.incrementsFromMiddle) * (self.ledgerLineSpace/2)
        noteSprite.position = CGPoint(x:size.width+(noteSprite.size.width/2), y:noteSpriteY)
        
        animateSpriteAcrossStaff(noteSprite, endXPos: -noteSprite.size.width/2, pixelsPerSecond: pixelsPerSecond, afterEnd:
            {(Void) -> Void in
                callbackFunc()
                noteSprite.removeFromParent()
            })
        
        addChild(noteSprite)
    }
    
    func setKeySignatureSprite(keySignatureSprite:KeySignatureSprite){
        self.currentKeySignatureSprite?.removeFromParent()
        
        keySignatureSprite.addAccidentals(ledgerLineSpace)
        keySignatureSprite.anchorPoint = CGPoint(x: 0, y: 0.5)
        let middlePosition = size.height/2
        keySignatureSprite.position = CGPoint(x: AnimatedStaff.keySigXPos, y: middlePosition)
        addChild(keySignatureSprite)
        
        self.currentKeySignatureSprite = keySignatureSprite
    }
    
    func animateKeySignatureSprite(keySignatureSprite:KeySignatureSprite, oldKeySignatureSprite:KeySignatureSprite, pixelsPerSecond:Double){
        oldKeySignatureSprite.addAccidentals(ledgerLineSpace)
        oldKeySignatureSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let keySignaturePadding = oldKeySignatureSprite.calculateAccumulatedFrame().width + 30
        oldKeySignatureSprite.position = CGPoint(x: -keySignaturePadding, y: 0)
        keySignatureSprite.addChild(oldKeySignatureSprite)
        
        keySignatureSprite.addAccidentals(ledgerLineSpace)
        keySignatureSprite.anchorPoint = CGPoint(x: 0, y: 0.5)
        let middlePosition = size.height/2
        keySignatureSprite.position = CGPoint(x: size.width+(keySignatureSprite.calculateAccumulatedFrame().width/2), y: middlePosition)
        
        animateSpriteAcrossStaff(keySignatureSprite, endXPos: AnimatedStaff.keySigXPos + keySignaturePadding, pixelsPerSecond: pixelsPerSecond, afterEnd:
            {(Void) -> Void in
                self.currentKeySignatureSprite!.removeFromParent()
                oldKeySignatureSprite.removeFromParent()
                self.currentKeySignatureSprite = keySignatureSprite
                self.animateSpriteAcrossStaff(keySignatureSprite, endXPos: AnimatedStaff.keySigXPos, pixelsPerSecond: pixelsPerSecond, afterEnd:{Void in})
            })
        addChild(keySignatureSprite)
    }
    
    func setClefSprite(clefSprite:SKSpriteNode){
        self.currentClefSprite?.removeFromParent()
        let middlePosition = size.height/2
        clefSprite.position = CGPoint(x: AnimatedStaff.clefXPos, y: middlePosition)
        self.currentClefSprite = clefSprite
        addChild(clefSprite)
    }
    
    func animateClefSprite(clefSprite:SKSpriteNode, pixelsPerSecond:Double,
        midwayCallbackFunc:(Void) -> Void, endCallbackFunc:(Void) -> Void){
        let middlePosition = size.height/2
        clefSprite.position = CGPoint(x: size.width+(clefSprite.size.width/2), y: middlePosition)
        animateSpriteAcrossStaff(clefSprite, endXPos: self.size.width/2, pixelsPerSecond: pixelsPerSecond, afterEnd:
            {(Void) -> Void in
                midwayCallbackFunc()
                self.animateSpriteAcrossStaff(clefSprite, endXPos: AnimatedStaff.clefXPos, pixelsPerSecond: pixelsPerSecond, afterEnd:
                    {Void in
                        endCallbackFunc()
                        self.currentClefSprite!.removeFromParent()
                        self.currentClefSprite = clefSprite
                    })
            })
        
        addChild(clefSprite)
    }
    
    private func createTempoMarkingSprite(bpm:Int) -> SKSpriteNode{
        let tempoMarkingSprite = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: 1, height: 1))
        
        let qNoteSprite = NoteSprite(
            note: Note(pitch: Pitch(absolutePitch: 0), rhythm: Rhythm.Quarter),
            incrementsFromMiddle: 0,
            ledgerLines: nil)
        qNoteSprite.addStem(true)
        qNoteSprite.position = CGPoint(x: 0, y: 0)
        tempoMarkingSprite.addChild(qNoteSprite)
        
        let tempoLabel:SKLabelNode = SKLabelNode(fontNamed: "Gotham-Bold")
        tempoLabel.text = "= " + String(bpm)
        tempoLabel.fontColor = UIColor.blackColor()
        tempoLabel.fontSize = 30
        tempoLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        tempoLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        tempoLabel.position = CGPoint(x: qNoteSprite.size.width, y: 0)
        tempoMarkingSprite.addChild(tempoLabel)
        
        return tempoMarkingSprite
    }
    
    func setTempoMarkingSprite(bpm:Int){
        self.currentTempoMarkingSprite?.removeFromParent()
        let tempoMarkingSprite = createTempoMarkingSprite(bpm)
        let middlePosition = size.height/2
        tempoMarkingSprite.position = CGPoint(x: AnimatedStaff.tempoXPos, y: middlePosition + (ledgerLineSpace * 5))
        self.currentTempoMarkingSprite = tempoMarkingSprite
        addChild(tempoMarkingSprite)
    }
    
    func animateTempoMarkingSprite(bpm:Int, pixelsPerSecond:Double){
        let tempoMarkingSprite = createTempoMarkingSprite(bpm)
        let middlePosition = size.height/2
        tempoMarkingSprite.position = CGPoint(x: size.width+(tempoMarkingSprite.size.width/2), y: middlePosition + (ledgerLineSpace * 5))
        
        animateSpriteAcrossStaff(tempoMarkingSprite, endXPos: AnimatedStaff.tempoXPos, pixelsPerSecond: pixelsPerSecond, afterEnd:
            {(Void) -> Void in
                self.currentTempoMarkingSprite!.removeFromParent()
                self.currentTempoMarkingSprite = tempoMarkingSprite
            })
        addChild(tempoMarkingSprite)
    }
    
    private func animateSpriteAcrossStaff(sprite:SKSpriteNode, endXPos:CGFloat, pixelsPerSecond:Double, afterEnd:(Void) -> Void){
        let distance = sprite.position.x - endXPos
        let timeToReachEndPoint:NSTimeInterval = NSTimeInterval(CGFloat((1/pixelsPerSecond)) * distance)
        let actionMove = SKAction.moveTo(
            CGPoint(x: endXPos, y: sprite.position.y),
            duration: timeToReachEndPoint)
        let actionMoveDone = SKAction.runBlock(afterEnd)
        sprite.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
}