//
//  KeyRange.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/26/15.
//  Copyright (c) 2015 Anthony Gabriele. All rights reserved.
//

import Foundation

class KeyRange:NSObject {
    var notes:Array<Note>
    let numIvoryKeys:Int
    
    init(lowNote:Note, highNote:Note){
        notes = Array<Note>()
        var numIvoryKeysMutable:Int = 0
        for currentAbsNote in lowNote.absoluteNote ... highNote.absoluteNote {
            let newNote = Note(absoluteNote:currentAbsNote)
            notes.append(newNote)
            if(newNote.isIvory){
                numIvoryKeysMutable++
            }
        }
        numIvoryKeys = numIvoryKeysMutable
    }
    
    func lowNote() -> Note{
        return notes.first!
    }
    
    func highNote() -> Note{
        return notes.last!
    }
    
    func ivoryIndex(midNote:Note) -> Int?{
        let lowNote = self.lowNote()
        let highNote = self.highNote()
        if(lowNote.absoluteNote <= midNote.absoluteNote
            && midNote.absoluteNote <= highNote.absoluteNote){
                var ivoryNoteCount:Int = 0
                if lowNote.absoluteNote < midNote.absoluteNote {
                    for currentNoteAbs in lowNote.absoluteNote ... midNote.absoluteNote - 1 {
                        let currentNoteIndex = currentNoteAbs - lowNote.absoluteNote
                        let currentNote:Note = self.notes[currentNoteIndex]
                        if currentNote.isIvory {
                            ivoryNoteCount++
                        }
                    }
                }
                return ivoryNoteCount
        }
        return nil
    }
}