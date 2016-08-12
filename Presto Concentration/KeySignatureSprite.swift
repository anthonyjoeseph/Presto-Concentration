//
//  KeySignatureSprite.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 12/27/15.
//  Copyright © 2015 Anthony Gabriele. All rights reserved.
//

import Foundation
import SpriteKit

class KeySignatureSprite: SKSpriteNode{
    
    private let xSpaceBetweenAccidentals:CGFloat = CGFloat(30)
    
    private var accidentalIncrements:[Int]
    private var accidental:Accidental
    private var overheadLetter:SKLabelNode? = nil
    
    init(accidentalIncrements:[Int], accidental:Accidental){
        self.accidentalIncrements = accidentalIncrements
        self.accidental = accidental
        super.init(texture: nil, color: UIColor.clearColor(), size: CGSize(width: 1, height: 1))
        self.anchorPoint = CGPoint(x: 0, y: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.accidentalIncrements = []
        self.accidental = Accidental.None
        super.init(coder: aDecoder)
    }
    
    func addAccidentals(ledgerLineSpace:CGFloat){
        var currentXPosition:CGFloat = CGFloat(0)
        for incrementsFromMiddle:Int in accidentalIncrements{
            let accidentalSprite:SKSpriteNode
            let noteHeight = ledgerLineSpace
            let desiredAccidentalHeight:CGFloat
            
            switch(accidental){
            case Accidental.Sharp:
                accidentalSprite = SKSpriteNode(imageNamed: "Sharp")
                desiredAccidentalHeight = noteHeight * 1.7
                break
            case Accidental.Flat:
                accidentalSprite = SKSpriteNode(imageNamed: "Flat")
                desiredAccidentalHeight = noteHeight * 2
                accidentalSprite.anchorPoint = CGPoint(x: 0.5, y: 0.25)
                break
            case Accidental.Natural:
                accidentalSprite = SKSpriteNode(imageNamed: "Natural")
                desiredAccidentalHeight = noteHeight * 1.7
                break
            default:
                accidentalSprite = SKSpriteNode(imageNamed: "Natural")
                desiredAccidentalHeight = noteHeight * 1.7
                break
            }
            
            let currentAccidentalHeight = accidentalSprite.size.height
            let heightScale = desiredAccidentalHeight/currentAccidentalHeight
            accidentalSprite.xScale = heightScale
            accidentalSprite.yScale = heightScale
            
            let positionOnStaff = CGPoint(x: currentXPosition, y: CGFloat(incrementsFromMiddle)*(ledgerLineSpace/2))
            accidentalSprite.position = positionOnStaff
            currentXPosition += xSpaceBetweenAccidentals
            self.addChild(accidentalSprite)
        }
    }
    
    func addOverheadLetter(letter:PitchLetter, accidental:KeyType){
        let letterLabel:SKLabelNode = SKLabelNode(fontNamed: "Gotham-Bold")
        var keyText = letter.rawValue
        keyText += accidental.rawValue
        letterLabel.text = keyText
        letterLabel.fontColor = UIColor.blackColor()
        letterLabel.fontSize = 50
        letterLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        letterLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        letterLabel.position = CGPoint(x: 0, y: 120)
        
        self.overheadLetter = letterLabel
        
        self.addChild(letterLabel)
    }
    
    func removeOverheadLetter(){
        self.overheadLetter?.removeFromParent()
    }
}
