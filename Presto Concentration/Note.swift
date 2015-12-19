//
//  Note.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/26/15.
//  Copyright (c) 2015 Anthony Gabriele. All rights reserved.
//

import Foundation

enum NoteLetter:String{
    case A = "A"
    case B = "B"
    case C = "C"
    case D = "D"
    case E = "E"
    case F = "F"
    case G = "G"
}

class Note:NSObject{
    let absoluteNote:Int
    let name:String
    let octave:Int
    let noteLetter:NoteLetter
    let isIvory:Bool
    
    init(absoluteNote:Int){
        self.absoluteNote = absoluteNote
        
        //determine the note's name
        let noteInOctave:Int = absoluteNote % 12
        
        switch(noteInOctave){
        case 0:
            isIvory = true
            self.noteLetter = NoteLetter.A
        case 1:
            isIvory = false
            self.noteLetter = NoteLetter.A
        case 2:
            isIvory = true
            self.noteLetter = NoteLetter.B
        case 3:
            isIvory = true
            self.noteLetter = NoteLetter.C
        case 4:
            isIvory = false
            self.noteLetter = NoteLetter.C
        case 5:
            isIvory = true
            self.noteLetter = NoteLetter.D
        case 6:
            isIvory = false
            self.noteLetter = NoteLetter.D
        case 7:
            isIvory = true
            self.noteLetter = NoteLetter.E
        case 8:
            isIvory = true
            self.noteLetter = NoteLetter.F
        case 9:
            isIvory = false
            self.noteLetter = NoteLetter.F
        case 10:
            isIvory = true
            self.noteLetter = NoteLetter.G
        case 11:
            isIvory = false
            self.noteLetter = NoteLetter.G
        default:
            isIvory = true
            self.noteLetter = NoteLetter.A
        }
        
        
        self.octave = absoluteNote / 12
        name = "\(self.octave)" + self.noteLetter.rawValue + ( isIvory ? "" : "s" )
    }
    
    func previousNote() -> Note{
        return Note(absoluteNote: absoluteNote-2)
    }
    
    func isSharp() -> Bool{
        return !isIvory
    }
    
    func ivoryDistance(comparisonNote:Note) -> Int{
        if self.absoluteNote == comparisonNote.absoluteNote {
            return 0
        }
        if self.absoluteNote > comparisonNote.absoluteNote {
            return -1 * comparisonNote.ivoryDistance(self)
        }
        var ivoriesBetween = 0
        for currentAbsoluteNote in self.absoluteNote ... comparisonNote.absoluteNote-1 {
            let currentNote = Note(absoluteNote: currentAbsoluteNote)
            if currentNote.isIvory {
                ivoriesBetween++
            }
        }
        return ivoriesBetween
    }
}