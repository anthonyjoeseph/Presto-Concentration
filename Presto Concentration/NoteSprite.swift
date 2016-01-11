//
//  NoteSprite.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/26/15.
//  Copyright (c) 2015 Anthony Gabriele. All rights reserved.
//

import Foundation
import SpriteKit

class NoteSprite: SKSpriteNode{
    
    let note:Note
    var ledgerLines:LedgerLines?
    var incrementsFromMiddle:Int
    
    init(note:Note, incrementsFromMiddle:Int, ledgerLines:LedgerLines?){
        self.note = note
        self.incrementsFromMiddle = incrementsFromMiddle
        self.ledgerLines = ledgerLines
        let texture = SKTexture(imageNamed:"WholeNote")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.ledgerLines = nil
        self.incrementsFromMiddle = 0
        self.note = Note(pitch: Pitch(absolutePitch:0), rhythm: Rhythm.Quarter)
        super.init(coder: aDecoder)
    }
    
    func addLetter(pitchLetter:PitchLetter){
        let letterLabel:SKLabelNode = SKLabelNode(fontNamed: "Arial")
        letterLabel.text = pitchLetter.rawValue
        letterLabel.fontColor = UIColor.blackColor()
        letterLabel.fontSize = 50
        letterLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        letterLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        letterLabel.position = CGPoint(x: self.size.width, y: 0)
        
        let background:SKSpriteNode =
            SKSpriteNode(color: UIColor.whiteColor(),
                size: CGSize(width: letterLabel.frame.size.width, height: letterLabel.frame.size.height));
        background.position = CGPointMake(0, 0);
        letterLabel.addChild(background)
        
        self.addChild(letterLabel)
    }
    
    func addAccidental(accidental:Accidental){
        switch(accidental){
        case Accidental.Natural:
            let natural = SKSpriteNode(imageNamed: "Natural")
            natural.position = CGPoint(x: -natural.size.width, y: 0)
            self.addChild(natural)
            break
        case Accidental.Sharp:
            let sharp = SKSpriteNode(imageNamed: "Sharp")
            sharp.position = CGPoint(x: -sharp.size.width, y: 0)
            self.addChild(sharp)
            break
        case Accidental.Flat:
            let flat = SKSpriteNode(imageNamed: "Flat")
            flat.position = CGPoint(x: -flat.size.width, y: 0)
            self.addChild(flat)
            break
        default:
            break
        }
    }
    
    func addLedgerLines(ledgerLineSpace:CGFloat){
        if let ledgerLinesDefinite = self.ledgerLines {
            for index in 0...ledgerLinesDefinite.NumLines-1{
                let ledgerLine = SKSpriteNode(imageNamed: "LedgerLine")
                var yPosition:CGFloat = CGFloat(index) * ledgerLineSpace
                if self.ledgerLines!.IsAboveStaff {
                    yPosition *= CGFloat(-1)
                    if(!ledgerLinesDefinite.IsOnLine){
                        yPosition -= ledgerLineSpace/CGFloat(2)
                    }
                }else{
                    if(!ledgerLinesDefinite.IsOnLine){
                        yPosition += ledgerLineSpace/CGFloat(2)
                    }
                }
                ledgerLine.position = CGPoint(x: 0, y: yPosition)
                self.addChild(ledgerLine)
            }
        }
    }
    
    func addStem(isUp:Bool){
        let stem = SKSpriteNode(imageNamed: "Stem")
        if(isUp){
            stem.anchorPoint = CGPoint(x: 1, y: 0)
            stem.position = CGPoint(x: self.size.width/2, y: 0)
        }else{
            stem.anchorPoint = CGPoint(x: 0, y: 1)
            stem.position = CGPoint(x: -self.size.width/2, y: 0)
        }
        self.addChild(stem)
    }
    
}