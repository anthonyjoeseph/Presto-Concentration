//
//  GamePersistence.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 1/12/16.
//  Copyright © 2016 Anthony Gabriele. All rights reserved.
//

import Foundation

class GamePersistence{
    
    //stored highest first, lowest last
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private static let HIGHSCORESKEY = "HighScores"
    private static let HIGHSCORESNAMESKEY = "HighScoreNames"
    private static let maxNumHighScores = 10
    
    
    //returns true if is a new high score
    func storeNewScore(score:Int, name:String) -> Bool{
        var highScores:Array<Int>
        var isHighScore:Bool
        
        if let savedHighScores = self.highScores() {
            highScores = savedHighScores
            if(score > highScores.last || highScores.count < 8){
                highScores.append(score)
                highScores.sortInPlace(>)
                if(highScores.count > 8){
                    highScores.removeLast()
                }
                isHighScore = true
            }else{
                isHighScore = false
            }
        }else{
            highScores = [score]
            isHighScore = true
        }
        if(isHighScore){
            userDefaults.setValue(highScores as NSArray, forKey: GamePersistence.HIGHSCORESKEY)
            var highScoreNames:Dictionary<Int, String>
            if let savedHighScoreNames = scoreNames(){
                highScoreNames = savedHighScoreNames
            }else{
                highScoreNames = Dictionary<Int, String>()
            }
            highScoreNames[score] = name
            //NSDictionaries can't have primitive keys, so the integer keys must be converted to strings
            var highScoreNamesConvertable:Dictionary = Dictionary<NSString, NSString>()
            for (key, value) in highScoreNames {
                let nsKey = String(key) as NSString
                let nsValue = value as NSString
                highScoreNamesConvertable[nsKey] = nsValue
            }
            userDefaults.setValue(highScoreNamesConvertable as NSDictionary, forKey: GamePersistence.HIGHSCORESNAMESKEY)
            
        }
        userDefaults.synchronize()
        
        return isHighScore
    }
    
    func highScores() -> Array<Int>?{
        let highScoresAnyOp = userDefaults.valueForKey("HighScores")
        if let highScoresAny = highScoresAnyOp{
            let highScoresNS = highScoresAny as! NSArray
            var highScores = [Int]()
            for scoreAny in highScoresNS {
                let score:Int = scoreAny as! Int
                highScores.append(score)
            }
            return highScores
        }
        return nil
    }
    
    func scoreNames() -> Dictionary<Int, String>?{
        let highScoreNamesAnyOp = userDefaults.valueForKey("HighScoreNames")
        if let highScoreNamesAny = highScoreNamesAnyOp{
            let highScoreNamesNS = highScoreNamesAny as! NSDictionary
            var highScoreNames:Dictionary = [Int : String]()
            for (key, value) in highScoreNamesNS {
                let keyAsInt:Int = (key as! NSString).integerValue
                let valueAsString:String = (value as! NSString) as String
                highScoreNames[keyAsInt] = valueAsString
            }
            return highScoreNames
        }
        return nil
    }
    func resetScores(){
        let domainName = NSBundle.mainBundle().bundleIdentifier!
        userDefaults.removePersistentDomainForName(domainName)
    }
}