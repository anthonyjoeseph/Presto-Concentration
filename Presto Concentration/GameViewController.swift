//
//  GameViewController.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 12/29/15.
//  Copyright © 2015 Anthony Gabriele. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    
    
    @IBOutlet var skViewOp:SKView?
    @IBOutlet var keyboardView:KeyboardView?
    
    static let secondsInMinute:Int = 60
    static let distanceBetweenBeats:Double = 60
    
    var difficultyLevel:DifficultyLevel = DifficultyLevel.Beginner
    var gameModel:GameModel
    var currentTimer:NSTimer = NSTimer()
    var staff:AnimatedStaff?
    
    var currentNotes:Set<NoteSprite> = Set()
    
    required init?(coder aDecoder: NSCoder) {
        self.gameModel = GameModel()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let skView = skViewOp!
        self.staff = AnimatedStaff(size: skView.bounds.size)
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        staff!.scaleMode = .ResizeFill
        skView.presentScene(staff)
        
        self.gameModel = GameModel()
        self.gameModel.currentDifficultyLevel = self.difficultyLevel
        self.resetTimer()
        
        //keyboard
        self.keyboardView?.pressedPitchesFunc = self.pitchesPressed
        self.keyboardView?.keyRange = GameModel.trebleKeyRange
        staff!.setKeySignatureSprite(self.createKeySignatureSprite(self.gameModel.currentKeySignature, isNaturals: false))
        staff!.setClefSprite(self.createClefSprite(self.gameModel.currentClef))
        staff!.setTempoMarkingSprite(self.gameModel.currentBPM)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //handle game model
    
    func setDifficultyLevel(difficultyLevel:DifficultyLevel){
        self.gameModel.currentDifficultyLevel = difficultyLevel
    }
    
    func update(){
        let newGameElement:GameElement = self.gameModel.pickNewElement()
        switch(newGameElement){
        case GameElement.Note:
            let newNote = self.gameModel.newNote()
            let newNoteSprite = self.createNoteSprite(newNote)
            self.staff!.animateNoteSprite(newNoteSprite, pixelsPerSecond: pixelsPerSecondFromTempo())
            break
        case GameElement.Tempo:
            self.gameModel.changeBPM()
            self.staff!.animateTempoMarkingSprite(self.gameModel.currentBPM, pixelsPerSecond: pixelsPerSecondFromTempo())
            self.resetTimer()
            break
        case GameElement.KeySignature:
            let newKeySignature = self.gameModel.changeKeySignature()
            let newKeySignatureSprite = self.createKeySignatureSprite(newKeySignature, isNaturals: false)
            self.staff!.animateKeySignatureSprite(newKeySignatureSprite, pixelsPerSecond: pixelsPerSecondFromTempo())
            break
        case GameElement.Clef:
            let newClef = self.gameModel.changeClef()
            let newClefSprite = self.createClefSprite(newClef)
            self.keyboardView?.keyRange = self.gameModel.currentKeyRange
            self.keyboardView?.setNeedsDisplay()
            self.staff!.animateClefSprite(newClefSprite, pixelsPerSecond: pixelsPerSecondFromTempo())
            break
        }
    }
    
    func resetTimer(){
        self.currentTimer.invalidate()
        let timeBetweenBeats:Double = Double(GameViewController.secondsInMinute)/Double(self.gameModel.currentBPM)
        self.currentTimer = NSTimer.scheduledTimerWithTimeInterval(timeBetweenBeats, target: self, selector: "update", userInfo: nil, repeats: true)
    }
    
    private func pixelsPerSecondFromTempo() -> Double{
        let pixelsPerBeat:Double = Double(self.staff!.size.width)/Double(8)
        let beatsPerSecond:Double = Double(self.gameModel.currentBPM)/Double(GameViewController.secondsInMinute)
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
    
    private func createKeySignatureSprite(keySignature:MajorKeySignature, isNaturals:Bool) -> KeySignatureSprite{
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
        let incrementsFromMiddle:[Int] = self.gameModel.currentClef
            .keySignatureAccidentalIncrementsFromMiddle(accidentalPitchLetters, isKeySharps: isKeySharps)
        return KeySignatureSprite(accidentalIncrements: incrementsFromMiddle, accidental: accidental)
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
        let fileName:String = String(pitch.absolutePitch) + ".aif"
        
    }
    
    //pause
    
    @IBAction func pauseButtonPressed(){
        self.staff!.paused = !self.staff!.paused
    }
}