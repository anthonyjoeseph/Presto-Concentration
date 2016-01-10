//
//  Clef.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/27/15.
//  Copyright (c) 2015 Anthony Gabriele. All rights reserved.
//

import Foundation

struct LedgerLines{
    let NumLines:Int
    let IsOnLine:Bool
    let IsAboveStaff:Bool
}

class Clef{
    static let numStepsInsideStaff:Int = 11
    let isTrebleClef:Bool
    let middlePitch:Pitch
    
    init(isTrebleClef:Bool){
        self.isTrebleClef = isTrebleClef
        if(isTrebleClef){
            self.middlePitch = Pitch(absolutePitch: 50)
        }else{
            self.middlePitch = Pitch(absolutePitch: 29)
        }
    }
    
    func incrementsFromMiddle(pitch:Pitch, keySignature:MajorKeySignature) -> Int{
        let relativeIvory = keySignature.relativeIvoryPitch(pitch)
        return Keyboard.ivoryDistance(self.middlePitch, comparisonPitch: relativeIvory)
    }
    
    func isStemUp(pitch:Pitch, keySignature:MajorKeySignature) -> Bool{
        return incrementsFromMiddle(pitch, keySignature: keySignature) < 0
    }
    
    func ledgerLines(pitch:Pitch, keySignature:MajorKeySignature) -> LedgerLines?{
        let numIncrementsFromMiddleInStaff:Int = 5
        let incrementsFromMiddleForPitch:Int = incrementsFromMiddle(pitch, keySignature: keySignature)
        let numIncrementsAbove:Int
        if(incrementsFromMiddleForPitch > numIncrementsFromMiddleInStaff){
            numIncrementsAbove = incrementsFromMiddleForPitch - numIncrementsFromMiddleInStaff
        }else if (incrementsFromMiddleForPitch < -numIncrementsFromMiddleInStaff){
            numIncrementsAbove = incrementsFromMiddleForPitch + numIncrementsFromMiddleInStaff
        }else{
            return nil
        }
        return LedgerLines(NumLines: (abs(numIncrementsAbove)+1)/2, IsOnLine: abs(numIncrementsAbove)%2==1, IsAboveStaff: numIncrementsAbove > 0)
    }
    func keySignatureAccidentalIncrementsFromMiddle(accidentalLetters:[PitchLetter], isKeySharps:Bool) -> [Int]{
        var allIncrements:[Int] = []
        for accidentalLetter in accidentalLetters{
            let baseAPitch:Pitch
            let highestPitch:Pitch
            if isTrebleClef {
                baseAPitch = Pitch(absolutePitch: 48)
                if(isKeySharps){
                    highestPitch = Pitch(absolutePitch: 58)
                }else{
                    highestPitch = Pitch(absolutePitch: 55)
                }
            }else{
                baseAPitch = Pitch(absolutePitch: 24)
                if(isKeySharps){
                    highestPitch = Pitch(absolutePitch: 34)
                }else{
                    highestPitch = Pitch(absolutePitch: 31)
                }
            }
            let basePitchForAccidental = lowestPitchForLetter(accidentalLetter)
            var accidentalPitch = Pitch(absolutePitch: basePitchForAccidental.absolutePitch + baseAPitch.absolutePitch)
            if(highestPitch.absolutePitch < accidentalPitch.absolutePitch){
                accidentalPitch = accidentalPitch.interval(Interval.PerfectOctave, intervalDirection: IntervalDirection.Down)
            }
            allIncrements.append(Keyboard.ivoryDistance(self.middlePitch, comparisonPitch: accidentalPitch))
        }
        return allIncrements
    }
}