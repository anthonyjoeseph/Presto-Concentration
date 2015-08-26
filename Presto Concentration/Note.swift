//
//  Note.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/26/15.
//  Copyright (c) 2015 Anthony Gabriele. All rights reserved.
//

import Foundation

class Note:NSObject{
    let absoluteNote:Int
    let name:String
    let isIvory:Bool
    
    init(absoluteNote:Int){
        self.absoluteNote = absoluteNote
        
        //determine the note's name
        let noteInOctave:Int = absoluteNote % 12
        let octave:Int = absoluteNote / 12
        
        var mutableName:String = String(octave)
        
        switch(noteInOctave){
        case 0:
            isIvory = true
            mutableName += "A"
        case 1:
            isIvory = false
            mutableName += "As"
        case 2:
            isIvory = true
            mutableName += "B"
        case 3:
            isIvory = true
            mutableName += "C"
        case 4:
            isIvory = false
            mutableName += "Cs"
        case 5:
            isIvory = true
            mutableName += "D"
        case 6:
            isIvory = false
            mutableName += "Ds"
        case 7:
            isIvory = true
            mutableName += "E"
        case 8:
            isIvory = true
            mutableName += "F"
        case 9:
            isIvory = false
            mutableName += "Fs"
        case 10:
            isIvory = true
            mutableName += "G"
        case 11:
            isIvory = false
            mutableName += "Gs"
        default:
            isIvory = true
            mutableName += "A"
        }
        name = mutableName
    }
    
    func previousNote() -> Note{
        return Note(absoluteNote: absoluteNote-2)
    }
    
}