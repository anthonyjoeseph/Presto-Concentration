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

class GameModel: NSObject{
    static let trebleKeyRange:KeyRange = KeyRange(lowPitch: Pitch(absolutePitch: 39), highPitch: Pitch(absolutePitch: 54))
    static let bassKeyRange:KeyRange = KeyRange(lowPitch: Pitch(absolutePitch: 27), highPitch: Pitch(absolutePitch: 42))
    static let defaultBPM:Int = 120
    static let secondsInMinute:Int = 60
    
    var currentTimer:NSTimer = NSTimer()
    var currentDifficultyLevel:DifficultyLevel?{
        didSet {
            if let definiteNewDifficultyLevel = self.currentDifficultyLevel {
                gameCountState = GameCountStateMachine(difficultyLevel: definiteNewDifficultyLevel)
                gameCountState.areNotesCleared = self.areNotesCleared
            }
        }
    }
    var gameCountState:GameCountStateMachine
    var currentBPM:Int
    var currentClef:Clef
    var previousKeySignature:MajorKeySignature
    var currentKeySignature:MajorKeySignature
    var currentKeyRange:KeyRange
    
    var updateStaffWithGameElement:(GameElement) -> Void
    var areNotesCleared: (Void) -> Bool
    
    convenience override init(){
        self.init(updateStaffWithGameElement: {(GameElement)->Void in}, areNotesCleared: {(Void) -> Bool in return true})
    }
    
    init(updateStaffWithGameElement:(GameElement) -> Void, areNotesCleared: (Void) -> Bool){
        self.updateStaffWithGameElement = updateStaffWithGameElement
        self.areNotesCleared = areNotesCleared
        
        self.currentBPM = GameModel.defaultBPM
        self.currentClef = Clef(isTrebleClef: true)
        self.currentKeySignature = MajorKeySignature(keyLetter: PitchLetter.C, keyAccidental: Accidental.None)!
        self.previousKeySignature = MajorKeySignature(keyLetter: PitchLetter.C, keyAccidental: Accidental.None)!
        self.currentKeyRange = GameModel.trebleKeyRange
        self.gameCountState = GameCountStateMachine(difficultyLevel: DifficultyLevel.Beginner)
        
        super.init()
        
        self.resetTimer()
    }
    
    func update(){
        if(!self.gameCountState.isWaiting()){
            let newGameElement = self.gameCountState.pickNewElement()
            switch(newGameElement){
            case GameElement.Clef:
                self.currentClef = newClef()
                if(self.currentClef.isTrebleClef){
                    self.currentKeyRange = GameModel.trebleKeyRange
                }else{
                    self.currentKeyRange = GameModel.bassKeyRange
                }
                break
            case GameElement.KeySignature:
                self.previousKeySignature = self.currentKeySignature
                self.currentKeySignature = newKeySignature()
                break
            case GameElement.Tempo:
                self.currentBPM = newBPM()
                self.resetTimer()
                break
            default:
                break
            }
            self.updateStaffWithGameElement(newGameElement)
        }
        self.gameCountState.updateCycle()
    }
    
    func resetTimer(){
        self.currentTimer.invalidate()
        let timeBetweenBeats:Double = Double(GameModel.secondsInMinute)/Double(self.currentBPM)
        self.currentTimer = NSTimer.scheduledTimerWithTimeInterval(timeBetweenBeats, target: self, selector: "update", userInfo: nil, repeats: true)
    }
    func stopTimer(){
        self.currentTimer.invalidate()
    }
    
    func newNote() -> Note{
        let randomPitch:Pitch
        if(self.gameCountState.isNewNoteInKey()){
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
    
    func newClef() -> Clef{
        let createdClef = Clef(isTrebleClef: !self.currentClef.isTrebleClef)
        if(self.currentClef.isTrebleClef){
            self.currentKeyRange = GameModel.trebleKeyRange
        }else{
            self.currentKeyRange = GameModel.bassKeyRange
        }
        return createdClef
    }
    
    func newKeySignature() -> MajorKeySignature{
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
    
    func newBPM() -> Int{
        return self.currentBPM + 5
    }
}