//
//  GameModel.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 12/29/15.
//  Copyright © 2015 Anthony Gabriele. All rights reserved.
//

import Foundation

enum GameElement{
    case Note, Clef, KeySignature, Tempo
}

enum DifficultyLevel{
    case Beginner, Intermediate, Expert
}

class GameModel{
    static let trebleKeyRange:KeyRange = KeyRange(lowPitch: Pitch(absolutePitch: 39), highPitch: Pitch(absolutePitch: 54))
    static let bassKeyRange:KeyRange = KeyRange(lowPitch: Pitch(absolutePitch: 27), highPitch: Pitch(absolutePitch: 42))
    static let defaultBPM:Int = 60
    
    var currentDifficultyLevel:DifficultyLevel
    var currentBPM:Int
    var currentClef:Clef
    var currentKeySignature:MajorKeySignature
    var currentKeyRange:KeyRange
    
    init(){
        self.currentDifficultyLevel = DifficultyLevel.Beginner
        self.currentBPM = GameModel.defaultBPM
        self.currentClef = Clef(isTrebleClef: false)
        self.currentKeySignature = MajorKeySignature(keyLetter: PitchLetter.B, keyAccidental: Accidental.None)!
        self.currentKeyRange = GameModel.bassKeyRange
    }
    
    func pickNewElement() -> GameElement{
        let random = arc4random_uniform(100)
        if(random < 80){
            return GameElement.Note
        }else if(random < 95){
            return GameElement.Clef
        }else if(random < 100){
            return GameElement.KeySignature
        }else{
            return GameElement.Tempo
        }
    }
    
    func newNote() -> Note{
        let randomPitch:Pitch
        if(self.currentDifficultyLevel == DifficultyLevel.Beginner){
            randomPitch = randomPitchInKey()
        }else{
            randomPitch = anyRandomPitch()
        }
        return Note(pitch: randomPitch, rhythm: Rhythm.Quarter)
    }
    
    private func anyRandomPitch() -> Pitch{
        let rangeSize:UInt32 = UInt32(self.currentKeyRange.highPitch().absolutePitch - self.currentKeyRange.lowPitch().absolutePitch)
        let randomIndex:Int = Int(arc4random_uniform(rangeSize))
        return self.currentKeyRange.pitches[randomIndex]
    }
    
    private func randomPitchInKey() -> Pitch{
        let randomPitch = anyRandomPitch()
        if(self.currentKeySignature.isInKey(randomPitch)){
            return randomPitch
        }
        return randomPitchInKey()
    }
    
    func changeClef() -> Clef{
        self.currentClef = Clef(isTrebleClef: !self.currentClef.isTrebleClef)
        if(self.currentClef.isTrebleClef){
            self.currentKeyRange = GameModel.trebleKeyRange
        }else{
            self.currentKeyRange = GameModel.bassKeyRange
        }
        return self.currentClef
    }
    
    func changeKeySignature() -> MajorKeySignature{
        let newKeyLetter:PitchLetter
        let randomLetterIndex = arc4random_uniform(7)
        switch(randomLetterIndex){
        case 0:
            newKeyLetter = PitchLetter.A
            break
        case 1:
            newKeyLetter = PitchLetter.B
            break
        case 2:
            newKeyLetter = PitchLetter.C
            break
        case 3:
            newKeyLetter = PitchLetter.D
            break
        case 4:
            newKeyLetter = PitchLetter.E
            break
        case 5:
            newKeyLetter = PitchLetter.F
            break
        case 6:
            newKeyLetter = PitchLetter.G
            break
        default:
            newKeyLetter = PitchLetter.A
            break
        }
        
        var newAccidental:Accidental
        let randomAccidentalIndex = arc4random_uniform(3)
        switch(randomAccidentalIndex){
        case 0:
            newAccidental = Accidental.None
            break
        case 1:
            newAccidental = Accidental.Flat
            break
        case 2:
            newAccidental = Accidental.Sharp
            break
        default:
            newAccidental = Accidental.None
            break
        }
        if(newKeyLetter == PitchLetter.B && newAccidental == Accidental.Sharp){
            newAccidental = Accidental.None
        }else if(newKeyLetter == PitchLetter.E && newAccidental == Accidental.Sharp){
            newAccidental = Accidental.None
        }else if(newKeyLetter == PitchLetter.F && newAccidental == Accidental.Flat){
            newAccidental = Accidental.None
        }else if(newKeyLetter == PitchLetter.G && newAccidental == Accidental.Sharp){
            newAccidental = Accidental.None
        }else if(newKeyLetter == PitchLetter.A && newAccidental == Accidental.Sharp){
            newAccidental = Accidental.None
        }else if(newKeyLetter == PitchLetter.D && newAccidental == Accidental.Sharp){
            newAccidental = Accidental.None
        }
        self.currentKeySignature = MajorKeySignature(keyLetter: newKeyLetter, keyAccidental: newAccidental)!
        return self.currentKeySignature
    }
    
    func changeBPM() -> Int{
        self.currentBPM = 60 + (Int(arc4random_uniform(10)) * 10)
        return self.currentBPM
    }
}