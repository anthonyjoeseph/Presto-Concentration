//
//  GameViewController.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 12/29/15.
//  Copyright © 2015 Anthony Gabriele. All rights reserved.
//

import UIKit
import SpriteKit
import AudioToolbox

class GameViewController: UIViewController {
    
    
    @IBOutlet var skViewOp:SKView?
    @IBOutlet var keyboardView:KeyboardView?
    
    static let distanceBetweenBeats:Double = 60
    
    var difficultyLevel:DifficultyLevel = DifficultyLevel.Beginner
    var gameModel:GameModel
    var staff:AnimatedStaff?
    
    var audioSounds:Dictionary<Int, SystemSoundID>
    
    var currentNotes:Set<NoteSprite> = Set()
    
    required init?(coder aDecoder: NSCoder) {
        self.audioSounds = Dictionary<Int, SystemSoundID>()
        self.gameModel = GameModel()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        loadSounds()
        
        let skView = skViewOp!
        self.staff = AnimatedStaff(size: skView.bounds.size)
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        staff!.scaleMode = .ResizeFill
        skView.presentScene(staff)
        
        self.gameModel.stopTimer()
        self.gameModel = GameModel(updateStaffWithGameElement: self.updateStaffWithGameElement, areNotesCleared: self.areNotesCleared)
        self.gameModel.currentDifficultyLevel = self.difficultyLevel
        
        //keyboard
        self.keyboardView?.pressedPitchesFunc = self.pitchesPressed
        self.keyboardView?.keyRange = self.gameModel.currentKeyRange
        if(self.difficultyLevel == DifficultyLevel.Beginner){
            self.keyboardView?.addKeyLetters()
        }
        staff!.setKeySignatureSprite(self.createKeySignatureSprite(self.gameModel.currentKeySignature, clef: self.gameModel.currentClef, isNaturals: false))
        staff!.setClefSprite(self.createClefSprite(self.gameModel.currentClef))
        staff!.setTempoMarkingSprite(self.gameModel.currentBPM)
    }
    
    func loadSounds(){
        for index:Int in 0...87 {
            var soundID:SystemSoundID = 0
            let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), String(index), "aif", nil)
            AudioServicesCreateSystemSoundID(soundURL, &soundID)
            self.audioSounds[index] = soundID
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //handle game model
    
    func setDifficultyLevel(difficultyLevel:DifficultyLevel){
        self.gameModel.currentDifficultyLevel = difficultyLevel
    }
    
    func updateStaffWithGameElement(newGameElement:GameElement){
        switch(newGameElement){
        case GameElement.Note:
            let newNote = self.gameModel.newNote()
            let newNoteSprite = self.createNoteSprite(newNote)
            self.staff!.animateNoteSprite(newNoteSprite, pixelsPerSecond: pixelsPerSecondFromTempo(), callbackFunc:
                {(Void) -> Void in
                    self.currentNotes.remove(newNoteSprite)
                })
            break
        case GameElement.KeySignature:
            let newKeySignatureSprite = self.createKeySignatureSprite(self.gameModel.currentKeySignature, clef: self.gameModel.currentClef, isNaturals: false)
            let oldKeySignatureSprite = self.createKeySignatureSprite(self.gameModel.previousKeySignature, clef: self.gameModel.currentClef, isNaturals: true)
            self.staff!.animateKeySignatureSprite(newKeySignatureSprite, oldKeySignatureSprite: oldKeySignatureSprite, pixelsPerSecond: pixelsPerSecondFromTempo())
            break
        case GameElement.Clef:
            let newClefSprite = self.createClefSprite(self.gameModel.currentClef)
            let keySigAtThisTime = self.gameModel.currentKeySignature
            let clefAtThisTime = self.gameModel.currentClef
            let clefsKeyRangeAtThisTime = self.gameModel.currentKeyRange
            self.staff!.animateClefSprite(newClefSprite, pixelsPerSecond: pixelsPerSecondFromTempo(), midwayCallbackFunc:
                {(Void) -> Void in
                    self.keyboardView?.keyRange = clefsKeyRangeAtThisTime
                },
                endCallbackFunc:
                {(Void) -> Void in
                    let newKeySigSprite = self.createKeySignatureSprite(keySigAtThisTime, clef: clefAtThisTime, isNaturals: false)
                    self.staff!.setKeySignatureSprite(newKeySigSprite)
                })
            break
        case GameElement.Tempo:
            self.staff!.animateTempoMarkingSprite(self.gameModel.currentBPM, pixelsPerSecond: pixelsPerSecondFromTempo())
            break
        }
    }
    
    func areNotesCleared() -> Bool{
        return self.currentNotes.count == 0
    }
    
    private func pixelsPerSecondFromTempo() -> Double{
        let pixelsPerBeat:Double = Double(self.staff!.size.width)/Double(8)
        let beatsPerSecond:Double = Double(self.gameModel.currentBPM)/Double(GameModel.secondsInMinute)
        let pixelsPerSecond = pixelsPerBeat * beatsPerSecond
        return pixelsPerSecond
    }
    
    func gameOver(){
        self.performSegueWithIdentifier("GameOver", sender: self)
    }
    
    //handle creating sprites
    
    private func createNoteSprite(note:Note) -> NoteSprite{
        let clef = self.gameModel.currentClef
        let keySignature = self.gameModel.currentKeySignature
        let incrementsFromMiddle:Int = clef.incrementsFromMiddle(note.pitch, keySignature: keySignature)
        
        let ledgerLines:LedgerLines? = clef.ledgerLines(note.pitch, keySignature: keySignature)
        let noteSprite = NoteSprite(note: note, incrementsFromMiddle: incrementsFromMiddle, ledgerLines:ledgerLines)
        noteSprite.addStem(clef.isStemUp(note.pitch, keySignature: keySignature))
        noteSprite.addAccidental(keySignature.accidental(note.pitch))
        if(self.difficultyLevel == DifficultyLevel.Beginner){
            noteSprite.addLetter(Keyboard.letterIfIvory(keySignature.relativeIvoryPitch(note.pitch))!)
        }
        
        self.currentNotes.insert(noteSprite)
        
        return noteSprite
    }
    
    private func createKeySignatureSprite(keySignature:MajorKeySignature, clef:Clef, isNaturals:Bool) -> KeySignatureSprite{
        let accidental:Accidental
        if(isNaturals){
            accidental = Accidental.Natural
        }else{
            if (keySignature.isKeySharps){
                accidental = Accidental.Sharp
            }else{
                accidental = Accidental.Flat
            }
        }
        let accidentalPitchLetters:[PitchLetter] = keySignature.accidentalPitchLetters
        let isKeySharps:Bool = keySignature.isKeySharps
        let incrementsFromMiddle:[Int] =
            clef.keySignatureAccidentalIncrementsFromMiddle(accidentalPitchLetters, isKeySharps: isKeySharps)
        let keySigSprite = KeySignatureSprite(accidentalIncrements: incrementsFromMiddle, accidental: accidental)
        
        if(!isNaturals){
            let keyAccidental:Accidental?
            if(keySignature.keyAccidental != Accidental.None){
                keyAccidental = keySignature.keyAccidental
            }else{
                keyAccidental = nil
            }
            keySigSprite.addOverheadLetter(keySignature.keyLetter, accidental: keyAccidental)
        }
        return keySigSprite
    }
    
    private func createClefSprite(clef:Clef) -> SKSpriteNode{
        let clefSprite:SKSpriteNode
        if clef.isTrebleClef {
            clefSprite = SKSpriteNode(imageNamed: "TrebleClef")
        }else{
            clefSprite = SKSpriteNode(imageNamed: "BassClef")
        }
        return clefSprite
    }
    
    //handle keyboard event
    
    func pitchesPressed(pitches:Set<Pitch>){
        for pitch:Pitch in pitches{
            playSound(pitch)
        }
        for noteSprite:NoteSprite in self.currentNotes{
            if(self.staff!.noteZone.containsPoint(noteSprite.position)){
                if(pitches.contains(noteSprite.note.pitch)){
                    self.currentNotes.remove(noteSprite)
                    noteSprite.removeFromParent()
                }
            }
        }
    }
    
    private func playSound(pitch:Pitch){
        let systemSound:SystemSoundID = self.audioSounds[pitch.absolutePitch]!
        AudioServicesPlaySystemSound(systemSound)
    }
}