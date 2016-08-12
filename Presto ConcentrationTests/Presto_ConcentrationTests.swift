//
//  Presto_ConcentrationTests.swift
//  Presto ConcentrationTests
//
//  Created by Anthony Gabriele on 8/19/15.
//  Copyright (c) 2015 Anthony Gabriele. All rights reserved.
//

import UIKit
import XCTest

@testable import Presto_Concentration

class Presto_ConcentrationTests: XCTestCase {
    
    let middleC:Pitch = Pitch.middleC
    let EAboveMiddleC:Pitch = Pitch.middleC.interval(Interval(distance:IntervalDistance.MajorThird, direction: IntervalDirection.Up))
    let FAboveMiddleC:Pitch = Pitch.middleC.interval(Interval(distance:IntervalDistance.PerfectFourth, direction: IntervalDirection.Up))
    let FSharpAboveMiddleC = Pitch.middleC.interval(Interval(distance:IntervalDistance.Tritone, direction: IntervalDirection.Up))
    let GBeneathMiddleC = Pitch.middleC.interval(Interval(distance:IntervalDistance.PerfectFourth, direction: IntervalDirection.Down))
    let DFlatAboveMiddleC = Pitch.middleC.interval(Interval(distance:IntervalDistance.HalfStep, direction: IntervalDirection.Up))
    let BFlatBelowMiddleC = Pitch.middleC.interval(Interval(distance:IntervalDistance.WholeStep, direction: IntervalDirection.Down))
    
    func testPitchFunctions() {
        XCTAssert(middleC.absolutePitch == 39, "Middle C")
        
        XCTAssert(FAboveMiddleC.absolutePitch == 44, "Interval up works")
        XCTAssert(GBeneathMiddleC.absolutePitch == 34, "Interval down works")
        
        let basePitch = middleC.basePitch()
        XCTAssert(basePitch == 3, "Base Pitch")
        
        let newMiddleCPitch = Pitch(absolutePitch: 39)
        XCTAssert(newMiddleCPitch == middleC, "equality operator overloading works")
    }
    
    func testKeyboardFunctions() {
        let lowC = lowestPitchForLetter(PitchLetter.C)
        XCTAssert(lowC.absolutePitch == 3, "Lowest Pitch for Letter Works")
        XCTAssert(Keyboard.isIvory(middleC) == true, "IsIvory for Ivory Works")
        XCTAssert(Keyboard.isIvory(DFlatAboveMiddleC) == false, "IsIvory for Ebony Works")
        
        let ivoryDistanceUpIvoryToIvory = Keyboard.staffDistanceIfIvories(middleC, comparisonPitch: FAboveMiddleC)
        XCTAssert(ivoryDistanceUpIvoryToIvory == 3, "Staff Distance Up Works")
        let ivoryDistanceDownIvoryToIvory = Keyboard.staffDistanceIfIvories(middleC, comparisonPitch: GBeneathMiddleC)
        XCTAssert(ivoryDistanceDownIvoryToIvory == -3, "Staff Distance Down Works")
        let ivoryDistanceSameIvoryToIvory = Keyboard.staffDistanceIfIvories(middleC, comparisonPitch: middleC)
        XCTAssert(ivoryDistanceSameIvoryToIvory == 0, "Staff Distance Same Works")
        let ivoryDistanceIvoryToEbony = Keyboard.staffDistanceIfIvories(middleC, comparisonPitch: DFlatAboveMiddleC)
        XCTAssert(ivoryDistanceIvoryToEbony == nil, "Staff Distance ebony (returns nil) Works")
        
        let pitchLetter:PitchLetter? = Keyboard.letterIfIvory(GBeneathMiddleC)
        XCTAssert(pitchLetter == PitchLetter.G, "Letter If Ivory Works")
        let noPitchLetter:PitchLetter? = Keyboard.letterIfIvory(DFlatAboveMiddleC)
        XCTAssert(noPitchLetter == nil, "Letter If Not Ivory Works")
    }
    
    func testKeyRangeFunctions(){
        let middleRange = KeyRange(lowPitch: middleC, highPitch: FAboveMiddleC)
        XCTAssert(middleRange.lowPitch().absolutePitch == 39, "KeyRange low pitch Works")
        XCTAssert(middleRange.highPitch().absolutePitch == 44, "KeyRange high pitch Works")
        let EWithinIvoryIndex = middleRange.ivoryIndex(EAboveMiddleC)
        XCTAssert(EWithinIvoryIndex == 2, "KeyRange ivory index Works")
        let BFlatBelowIvoryIndex = middleRange.ivoryIndex(BFlatBelowMiddleC)
        XCTAssert(BFlatBelowIvoryIndex == nil, "KeyRange ivory index out of bounds Works")
    }
    
}
