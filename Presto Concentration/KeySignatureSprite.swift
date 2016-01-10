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
    
    var accidentalIncrements:[Int]
    var accidental:Accidental
    
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
            switch(accidental){
            case Accidental.Sharp:
                accidentalSprite = SKSpriteNode(imageNamed: "Sharp")
                break
            case Accidental.Flat:
                accidentalSprite = SKSpriteNode(imageNamed: "Flat")
                break
            case Accidental.Natural:
                accidentalSprite = SKSpriteNode(imageNamed: "Natural")
                break
            default:
                accidentalSprite = SKSpriteNode(imageNamed: "Natural")
                break
            }
            let positionOnStaff = CGPoint(x: currentXPosition, y: CGFloat(incrementsFromMiddle)*(ledgerLineSpace/2))
            accidentalSprite.position = positionOnStaff
            currentXPosition += CGFloat(30)
            self.addChild(accidentalSprite)
        }
    }
}
