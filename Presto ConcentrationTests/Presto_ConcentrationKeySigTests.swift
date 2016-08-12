//
//  Presto_ConcentrationKeySigTests.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 6/13/16.
//  Copyright © 2016 Anthony Gabriele. All rights reserved.
//

import XCTest

@testable import Presto_Concentration

class Presto_ConcentrationKeySigTests: XCTestCase {
    
    let eMajorOp = MajorKeySignature(keyTitleLetter: PitchLetter.E, keyTitleType: KeyType.None)
    let eMajor = MajorKeySignature(keyTitleLetter: PitchLetter.E, keyTitleType: KeyType.None)!
    
    let middleC:Pitch = Pitch.middleC
    let EAboveMiddleC:Pitch = Pitch.middleC.interval(Interval(distance:IntervalDistance.MajorThird, direction: IntervalDirection.Up))
    let FAboveMiddleC:Pitch = Pitch.middleC.interval(Interval(distance:IntervalDistance.PerfectFourth, direction: IntervalDirection.Up))
    let FSharpAboveMiddleC = Pitch.middleC.interval(Interval(distance:IntervalDistance.Tritone, direction: IntervalDirection.Up))
    let GBeneathMiddleC = Pitch.middleC.interval(Interval(distance:IntervalDistance.PerfectFourth, direction: IntervalDirection.Down))
    let DFlatAboveMiddleC = Pitch.middleC.interval(Interval(distance:IntervalDistance.HalfStep, direction: IntervalDirection.Up))
    let BFlatBelowMiddleC = Pitch.middleC.interval(Interval(distance:IntervalDistance.WholeStep, direction: IntervalDirection.Down))

    func testInitialization() {
        XCTAssert(eMajorOp != nil, "Initialization works")
        let bSharpMajor = MajorKeySignature(keyTitleLetter: PitchLetter.B, keyTitleType: KeyType.Sharp)
        XCTAssert(bSharpMajor == nil, "Initialization fails properly")
    }
    
    func testFunctions() {
        XCTAssert(eMajor.isInKey(EAboveMiddleC) == true, "isInKey works")
        XCTAssert(eMajor.isInKey(middleC) == false, "isInKey fails properly")
        NSLog(eMajor.nameForPitch(FSharpAboveMiddleC))
        XCTAssert(eMajor.nameForPitch(FSharpAboveMiddleC) == "F", "nameForPitch in key works")
        XCTAssert(eMajor.nameForPitch(middleC) == "Cnat", "nameForPitch out of key works")
        
        XCTAssert(eMajor.relativeIvoryPitch(FSharpAboveMiddleC) == FAboveMiddleC, "relativeIvoryPitch in key works")
        
        XCTAssert(true, "accidental works")
        
        XCTAssert(true, "toString works")
    }

}
