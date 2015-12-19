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
    
    var note:Note?{
        get{
            return self.note
        }
        set(newNote){
            self.note = newNote
            addAccidentals()
            addStem()
            addLedgerLines()
        }
    }
    
    init(imageNamed:String){
        let texture = SKTexture(imageNamed:imageNamed)
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addAccidentals(){
        
    }
    
    func addStem(){
        //nothing yet
        //probably want to adjust the anchorpoint
    }
    
    func addLedgerLines(){
        //nothing yet
    }
    
}