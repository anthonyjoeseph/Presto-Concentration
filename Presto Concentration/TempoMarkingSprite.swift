//
//  TempoMarkingSprite.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 12/29/15.
//  Copyright © 2015 Anthony Gabriele. All rights reserved.
//

import Foundation
import SpriteKit

class TempoMarkingSprite:SKSpriteNode{
    
    init(tempoMarking:Int){
        super.init(texture: nil, color: UIColor.clearColor(), size: CGSize(width: 1, height: 1))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}