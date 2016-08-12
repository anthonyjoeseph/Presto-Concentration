//
//  NoteAndClefState.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 1/11/16.
//  Copyright © 2016 Anthony Gabriele. All rights reserved.
//

import Foundation

class NoteAndClefState:GameCountState{
    var stateMachine:GameCountStateMachine?
    var noteCountSinceNewKeySignature:Int = 0
    var noteCountSinceNewClef:Int = 0
    var noteCountSinceTempoChange:Int = 0
    
    private func oddsOfNewClef() -> Float{
        if(noteCountSinceNewClef > 6){
            switch(self.stateMachine!.difficultyLevel){
            case DifficultyLevel.Beginner:
                return 0
            case DifficultyLevel.Intermediate:
                return 0.3
            case DifficultyLevel.Expert:
                return 0.3
            }
        }else{
            return 0
        }
    }
    
    private func oddsOfNewKeySignature() -> Float{
        if(noteCountSinceNewKeySignature > 6){
            switch(self.stateMachine!.difficultyLevel){
            case DifficultyLevel.Beginner:
                return 0
            case DifficultyLevel.Intermediate:
                return 0
            case DifficultyLevel.Expert:
                return 0.3
            }
        }else{
            return 0
        }
    }
    
    private func randomFromZeroToOne() -> Float{
        return Float(arc4random()) / Float(UINT32_MAX)
    }
    
    private func randomElement() -> GameElement{
        var random:Float = randomFromZeroToOne()
        if(random < oddsOfNewKeySignature()){
            return GameElement.KeySignature
        }
        random -= oddsOfNewKeySignature()
        if(random < oddsOfNewClef()){
            return GameElement.Clef
        }
        return GameElement.Note
    }
    
    func isWaiting() -> Bool{
        if(noteCountSinceTempoChange >= 20){
            noteCountSinceTempoChange = 0
            self.stateMachine!.changeState(CountState.TempoChangeState)
            return true
        }
        return false
    }
    func pickNewElement() -> GameElement{
        var newElement = randomElement()
        if(newElement == GameElement.KeySignature){
            newElement = GameElement.Note
        }
        switch(newElement){
        case GameElement.Note:
            noteCountSinceTempoChange += 1
            noteCountSinceNewClef += 1
            noteCountSinceNewKeySignature += 1
            break
        case GameElement.Clef:
            noteCountSinceNewClef = 0
            break
        default:
            break
        }
        return newElement
    }
    func updateCycle(){
        let randElement = randomElement()
        if(randElement == GameElement.KeySignature){
            noteCountSinceNewKeySignature = 0
            self.stateMachine!.changeState(CountState.KeySignatureChangeState)
        }
    }
}