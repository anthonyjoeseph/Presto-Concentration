//
//  MajorKeySignature.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 12/20/15.
//  Copyright © 2015 Anthony Gabriele. All rights reserved.
//

import Foundation

enum Accidental:String {
    case None = "", Natural = "nat", Sharp = "#", Flat = "b";
}

class MajorKeySignature{
    let keyLetter:PitchLetter
    let keyAccidental:Accidental
    let isKeySharps:Bool
    var accidentalPitchLetters:[PitchLetter]
    var accidentals:Dictionary<Int, Accidental>
    
    init?(keyLetter:PitchLetter, keyAccidental:Accidental){
        self.keyLetter = keyLetter
        self.keyAccidental = keyAccidental
        self.accidentalPitchLetters = []
        self.accidentals = Dictionary<Int, Accidental>()
        
        if(keyLetter == PitchLetter.C){
            self.isKeySharps = false
        }else if((keyAccidental == Accidental.None && keyLetter != PitchLetter.F) || keyAccidental == Accidental.Sharp){
            self.isKeySharps = true
        }else{
            self.isKeySharps = false
        }
        
        if keyAccidental == Accidental.Natural {
            return nil
        }
        if (keyLetter == PitchLetter.F && keyAccidental == Accidental.Flat) ||
            (keyLetter == PitchLetter.E && keyAccidental == Accidental.Sharp) ||
            (keyLetter == PitchLetter.G && keyAccidental == Accidental.Sharp) ||
            (keyLetter == PitchLetter.B && keyAccidental == Accidental.Sharp) ||
            (keyLetter == PitchLetter.A && keyAccidental == Accidental.Sharp) ||
            (keyLetter == PitchLetter.D && keyAccidental == Accidental.Sharp){
            return nil
        }
        
        populateAccidentalPitchLetters()
        
        populateAccidentals()
    }
    
    private func populateAccidentalPitchLetters(){
        if(keyLetter == PitchLetter.C && (keyAccidental == Accidental.None || keyAccidental == Accidental.Natural)){
            self.accidentalPitchLetters = []
        }else{
            let accidentalsInOrder:[PitchLetter]
            var absolutePitchFromKeyLetter = lowestPitchForLetter(self.keyLetter).absolutePitch + 36 //three octaves up
            if(self.keyAccidental == Accidental.Flat){
                absolutePitchFromKeyLetter--
            }else if(self.keyAccidental == Accidental.Sharp){
                absolutePitchFromKeyLetter++
            }
            let pitchFromKeyLetter = Pitch(absolutePitch: absolutePitchFromKeyLetter)
            let numFourthsFromC:Int
            let intervalDirection:IntervalDirection
            if(isKeySharps){
                accidentalsInOrder = [PitchLetter.F, PitchLetter.C, PitchLetter.G, PitchLetter.D,
                    PitchLetter.A, PitchLetter.E, PitchLetter.B]
                intervalDirection = IntervalDirection.Down
            }else{
                accidentalsInOrder = [PitchLetter.B, PitchLetter.E, PitchLetter.A, PitchLetter.D,
                    PitchLetter.G, PitchLetter.C, PitchLetter.F]
                intervalDirection = IntervalDirection.Up
            }
            numFourthsFromC = fourthsFromC(pitchFromKeyLetter, intervalDirection: intervalDirection)
            self.accidentalPitchLetters = Array(accidentalsInOrder[0...numFourthsFromC-1])
        }
    }
    
    private func fourthsFromC(relativePitch:Pitch, intervalDirection:IntervalDirection) -> Int{
        var currentPitch = Pitch.middleC
        var fourthCounter = 0
        while (currentPitch.basePitch()) != (relativePitch.basePitch()){
            currentPitch = currentPitch.interval(Interval.PerfectFourth, intervalDirection: intervalDirection)
            fourthCounter++
        }
        return fourthCounter
    }
    
    private func populateAccidentals(){
        var tonicPitch:Pitch = lowestPitchForLetter(self.keyLetter).interval(Interval.PerfectOctave, intervalDirection: IntervalDirection.Up)
        let nextPitchAccidental:Accidental
        
        switch(self.keyAccidental){
        case Accidental.Flat:
            tonicPitch = tonicPitch.interval(Interval.HalfStep, intervalDirection: IntervalDirection.Down)
            nextPitchAccidental = Accidental.Natural
            break
        case Accidental.Sharp:
            tonicPitch = tonicPitch.interval(Interval.HalfStep, intervalDirection: IntervalDirection.Up)
            nextPitchAccidental = Accidental.Natural
            break
        default:
            let halfStepUp:Pitch = tonicPitch.interval(Interval.HalfStep, intervalDirection: IntervalDirection.Up)
            if Keyboard.isIvory(halfStepUp) {
                nextPitchAccidental = Accidental.Natural
            }else{
                nextPitchAccidental = Accidental.Flat
            }
            break
        }
        self.accidentals[tonicPitch.basePitch()] = Accidental.None
        self.accidentals[tonicPitch.interval(Interval.HalfStep, intervalDirection: IntervalDirection.Up).basePitch()]
            = nextPitchAccidental
        
        let majorScaleSteps:[Interval] =
            [Interval.WholeStep, Interval.HalfStep, Interval.WholeStep, Interval.WholeStep,
                Interval.WholeStep, Interval.WholeStep]
        let possibleAccidentals = [Accidental.Flat, Accidental.None, Accidental.Sharp, Accidental.Flat, Accidental.Flat]
        var currentPitch:Pitch = tonicPitch.interval(Interval.WholeStep, intervalDirection: IntervalDirection.Up)
        for index:Int in 0...4{
            self.accidentals[currentPitch.basePitch()] = Accidental.None
            let halfStepUp:Pitch = currentPitch.interval(Interval.HalfStep, intervalDirection: IntervalDirection.Up)
            if Keyboard.isIvory(halfStepUp) {
                self.accidentals[halfStepUp.basePitch()] = Accidental.Natural
            }else{
                self.accidentals[halfStepUp.basePitch()] = possibleAccidentals[index]
            }
            currentPitch = currentPitch.interval(majorScaleSteps[index], intervalDirection: IntervalDirection.Up)
        }
        self.accidentals[currentPitch.basePitch()] = Accidental.None
    }
    
    func isInKey(pitch:Pitch) -> Bool{
        return accidental(pitch) == Accidental.None;
    }
    
    func nameForPitch(pitch:Pitch) -> String{
        let relativeIvory = relativeIvoryPitch(pitch)
        let accidentalRaw = accidental(pitch).rawValue
        let letter = Keyboard.letterIfIvory(relativeIvory)!
        return letter.rawValue + accidentalRaw;
    }
    
    func relativeIvoryPitch(pitch:Pitch) -> Pitch{
        var absoluteIvoryPitch:Int = 0
        
        switch(accidental(pitch)){
        case Accidental.None:
            if(Keyboard.isIvory(pitch)){
                if(self.isKeySharps){
                    let halfStepDown = pitch.interval(Interval.HalfStep, intervalDirection: IntervalDirection.Down)
                    if(Keyboard.isIvory(halfStepDown) &&
                        self.accidentalPitchLetters.contains(Keyboard.letterIfIvory(halfStepDown)!)){
                        absoluteIvoryPitch = pitch.absolutePitch - 1
                    }else{
                        absoluteIvoryPitch = pitch.absolutePitch
                    }
                }else{
                    let halfStepUp = pitch.interval(Interval.HalfStep, intervalDirection: IntervalDirection.Up)
                    if(Keyboard.isIvory(halfStepUp) &&
                        self.accidentalPitchLetters.contains(Keyboard.letterIfIvory(halfStepUp)!)){
                            absoluteIvoryPitch = pitch.absolutePitch + 1
                    }else{
                        absoluteIvoryPitch = pitch.absolutePitch
                    }
                }
            }else{
                if(isKeySharps){
                    absoluteIvoryPitch = pitch.absolutePitch - 1
                }else{
                    absoluteIvoryPitch = pitch.absolutePitch + 1
                }
            }
            break
        case Accidental.Natural:
            absoluteIvoryPitch = pitch.absolutePitch
            break
        case Accidental.Flat:
            absoluteIvoryPitch = pitch.absolutePitch + 1
            break
        case Accidental.Sharp:
            absoluteIvoryPitch = pitch.absolutePitch - 1
            break
        }
        return Pitch(absolutePitch: absoluteIvoryPitch);
    }
    
    func accidental(pitch:Pitch) -> Accidental{
        return self.accidentals[pitch.basePitch()]!;
    }
    
    func toString() -> String{
        return self.keyLetter.rawValue + self.keyAccidental.rawValue
    }
}