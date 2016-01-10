//
//  Note.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/26/15.
//  Copyright (c) 2015 Anthony Gabriele. All rights reserved.
//

import Foundation

enum Rhythm:Int{
    case ThirtySecond = 1
    case Sixteenth = 2
    case Eighth = 4
    case Quarter = 8
    case Half = 16
    case Whole = 32
}

struct Note {
    let pitch:Pitch
    let rhythm:Rhythm
}