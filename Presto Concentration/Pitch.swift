//
//  Pitch.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 12/21/15.
//  Copyright © 2015 Anthony Gabriele. All rights reserved.
//

import Foundation

enum Interval:Int{
    case HalfStep = 1
    case WholeStep = 2
    case MinorThird = 3
    case MajorThird = 4
    case PerfectFourth = 5
    case Tritone = 6
    case PerfectFifth = 7
    case MinorSixth = 8
    case MajorSixth = 9
    case MinorSeventh = 10
    case MajorSeventh = 11
    case PerfectOctave = 12
}

enum IntervalDirection:Int{
    case Down = 0
    case Up = 1
}

class Pitch:Equatable, Hashable{
    let absolutePitch:Int
    let octave:Int
    
    var hashValue: Int {
        return absolutePitch
    }
    
    static let middleC:Pitch = Pitch(absolutePitch:39)
    
    init(absolutePitch:Int){
        self.absolutePitch = absolutePitch
        self.octave = absolutePitch / 12
    }
    func interval(interval:Interval, intervalDirection:IntervalDirection) -> Pitch{
        var newAbsolutePitch:Int
        if(intervalDirection == IntervalDirection.Down){
            newAbsolutePitch = self.absolutePitch - interval.rawValue
            if(newAbsolutePitch < 0){
                newAbsolutePitch += 84
            }
        }else{
            newAbsolutePitch = self.absolutePitch + interval.rawValue
            if(newAbsolutePitch >= 88){
                newAbsolutePitch -= 84
            }
        }
        return Pitch(absolutePitch: newAbsolutePitch)
    }
    func basePitch() -> Int{
        return absolutePitch % 12
    }
}

func ==(lhs: Pitch, rhs: Pitch) -> Bool {
    return lhs.absolutePitch == rhs.absolutePitch
}
