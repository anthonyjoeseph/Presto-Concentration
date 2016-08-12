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
    @IBOutlet var countdownTimerImage:UIImageView?
    
    static let distanceBetweenBeats:Double = 60
    
    var difficultyLevel:DifficultyLevel = DifficultyLevel.Beginner
    var gameModel:GameModel
    var staff:AnimatedStaff?
    private var score:Int = 0{
        didSet{
            self.staff!.scoreNode.text = String(score)
        }
    }
    
    private var countdownTimer:NSTimer?
    private var countdownTimerCount = 3
    private let countdownImageTwo:UIImage = UIImage(named: "countdown2")!
    private let countdownImageOne:UIImage = UIImage(named: "countdown1")!
    
    var audioSounds:Dictionary<Int, SystemSoundID>
    
    var currentNotes:Set<NoteSprite> = Set()
    
    required init?(coder aDecoder: NSCoder) {
        self.audioSounds = Dictionary<Int, SystemSoundID>()
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
        
        self.keyboardView?.pressedPitchesFunc = self.pitchesPressed
        self.keyboardView?.releasedFunc = self.keysReleased
        self.keyboardView?.keyRange = self.gameModel.currentKeyRange
        if(self.difficultyLevel == DifficultyLevel.Beginner){
            self.keyboardView?.keysHaveLetters = true
        }else{
            self.keyboardView?.keysHaveLetters = false
        }
        staff!.setKeySignatureSprite(self.createKeySignatureSprite(self.gameModel.currentKeySignature, clef: self.gameModel.currentClef, isNaturals: false))
        staff!.setClefSprite(self.createClefSprite(self.gameModel.currentClef))
        staff!.setTempoMarkingSprite(self.gameModel.currentBPM)
    }
    
    override func viewDidAppear(animated:Bool) {
        super.viewDidAppear(animated)
        
        loadSounds()
        
        self.gameModel = GameModel(updateStaffWithGameElement: self.updateStaffWithGameElement, areNotesCleared: self.areNotesCleared)
        self.gameModel.currentDifficultyLevel = self.difficultyLevel
        
        self.score = 0
        self.countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(GameViewController.countdownTimerTick), userInfo: nil, repeats: true)
        
        var soundID:SystemSoundID = 0
        let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "silent", "mp3", nil)
        AudioServicesCreateSystemSoundID(soundURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }
    
    @objc func countdownTimerTick(){
        if self.countdownTimerCount == 2 {
            self.countdownTimerImage?.image = self.countdownImageTwo
        }else if self.countdownTimerCount == 1 {
            self.countdownTimerImage?.image = self.countdownImageOne
        }else if self.countdownTimerCount <= 0{
            self.gameModel.resetTimer()
            self.countdownTimerImage?.hidden = true
            self.countdownTimer!.invalidate()
            self.countdownTimer = nil
        }
        self.countdownTimerCount -= 1
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
    /*
    func updateStaffWithGameElementNew(newGameElement:GameElement){
        let element:SKSpriteNode = StaffSpriteFactories.createGameElementSprite(newGameElement)
        let callbacks = gameElementCallbackMethods(newGameElement)
        self.staff!.animateSprite(newGameElement, callbacks, pickestPerSecondFromTempo())
    }*/
    
    func updateStaffWithGameElement(newGameElement:GameElement){
        switch(newGameElement){
        case GameElement.Note:
            let newNote = self.gameModel.newNote()
            let newNoteSprite = self.createNoteSprite(newNote)
            self.staff!.animateNoteSprite(newNoteSprite, pixelsPerSecond: pixelsPerSecondFromTempo(), callbackFunc:
                {(Void) -> Void in
                    self.currentNotes.remove(newNoteSprite)
                    self.gameOver()
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
    
    private func pixelsPerSecondFromTempo() -> Double{
        let pixelsPerBeat:Double = Double(self.staff!.size.width)/Double(8)
        let beatsPerSecond:Double = Double(self.gameModel.currentBPM)/Double(GameModel.secondsInMinute)
        let pixelsPerSecond = pixelsPerBeat * beatsPerSecond
        return pixelsPerSecond
    }
    
    //game model delegate
    
    func areNotesCleared() -> Bool{
        return self.currentNotes.count == 0
    }
    
    //handle creating sprites
    
    private func createNoteSprite(note:Note) -> NoteSprite{
        let clef = self.gameModel.currentClef
        let keySignature = self.gameModel.currentKeySignature
        let incrementsFromMiddle:Int = clef.incrementsFromMiddle(note.pitch, keySignature: keySignature)
        
        let ledgerLines:LedgerLines? = clef.ledgerLines(note.pitch, keySignature: keySignature)
        let noteSprite = NoteSprite(note: note, incrementsFromMiddle: incrementsFromMiddle, ledgerLines:ledgerLines)
        let isStemUp = clef.isStemUp(note.pitch, keySignature: keySignature)
        noteSprite.addStem(isStemUp)
        noteSprite.addAccidental(keySignature.nonSolfegAccidental(note.pitch))
        if(self.difficultyLevel == DifficultyLevel.Beginner){
            noteSprite.addLetter(Keyboard.letterIfIvory(keySignature.relativeIvoryPitch(note.pitch))!, isStemInTheWay: !isStemUp)
        }
        
        self.currentNotes.insert(noteSprite)
        
        return noteSprite
    }
    
    private func createKeySignatureSprite(keySignature:MajorKeySignature, clef:Clef, isNaturals:Bool) -> KeySignatureSprite{
        let accidental:Accidental
        if(isNaturals){
            accidental = Accidental.Natural
        }else{
            if (keySignature.keyType == KeyType.Sharp){
                accidental = Accidental.Sharp
            }else{
                accidental = Accidental.Flat
            }
        }
        let accidentalPitchLetters:[PitchLetter] = keySignature.getAccidentalPitchLetters()
        let incrementsFromMiddle:[Int] =
            clef.keySignatureAccidentalIncrementsFromMiddle(accidentalPitchLetters, keyType: keySignature.keyType)
        let keySigSprite = KeySignatureSprite(accidentalIncrements: incrementsFromMiddle, accidental: accidental)
        
        if(!isNaturals){
            keySigSprite.addOverheadLetter(keySignature.keyTitleLetter, accidental: keySignature.keyTitleType)
        }
        return keySigSprite
    }
    
    private func createClefSprite(clef:Clef) -> SKSpriteNode{
        let clefSprite:SKSpriteNode
        
        let staffHeight = self.staff!.staffNode.size.height
        let desiredClefHeight:CGFloat
        if clef.isTrebleClef {
            clefSprite = SKSpriteNode(imageNamed: "TrebleClef")
            desiredClefHeight = staffHeight * 1.7
        }else{
            clefSprite = SKSpriteNode(imageNamed: "BassClef")
            clefSprite.anchorPoint = CGPoint(x: 0.5, y: 0.4)
            desiredClefHeight = staffHeight * 0.7
        }
        
        let currentClefHeight = clefSprite.size.height
        let heightScale = desiredClefHeight/currentClefHeight
        clefSprite.xScale = heightScale
        clefSprite.yScale = heightScale
        
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
                    updateScoreWithOneNote()
                    self.currentNotes.remove(noteSprite)
                    noteSprite.removeFromParent()
                }else{
                    score -= 10
                }
            }
        }
        self.staff!.pressNoteZone()
    }
    
    func keysReleased(){
        self.staff!.releaseNoteZone()
    }
    
    private func playSound(pitch:Pitch){
        let systemSound:SystemSoundID = self.audioSounds[pitch.absolutePitch]!
        AudioServicesPlaySystemSound(systemSound)
    }
    
    //handle score
    
    private func updateScoreWithOneNote(){
        switch(self.difficultyLevel){
        case DifficultyLevel.Beginner:
            score += 100
            break
        case DifficultyLevel.Intermediate:
            score += 200
            break
        case DifficultyLevel.Expert:
            score += 1000
            break
        }
    }
    
    //handle game over
    
    func gameOver(){
        let gameData = GamePersistence()
        gameData.storeNewScore(self.score, name: "GEB")
        self.performSegueWithIdentifier("GameOver", sender: self)
    }
}