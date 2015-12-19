//
//  KeyboardView.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/26/15.
//  Copyright (c) 2015 Anthony Gabriele. All rights reserved.
//

import Foundation
import UIKit

class KeyboardView: UIView{
    
    private let ivoryToEbonyWidth:CGFloat = 0.7
    private let ivoryToEbonyHeight:CGFloat = 0.5
    
    var keyRange:KeyRange
    private var keys:Array<KeyBase> = []
    
    //defined in "layoutSubviews"
    private var ivoryWidth:CGFloat = 0
    private var ivoryHeight:CGFloat = 0
    private var ebonyWidth:CGFloat = 0
    private var ebonyHeight:CGFloat = 0
    
    var pressedNotesFunc: (Set<Note>) -> Void

    required init?(coder aDecoder: NSCoder) {
        self.keyRange = KeyRange(lowNote: Note(absoluteNote: 39), highNote: Note(absoluteNote: 53))
        //empty, client can override
        self.pressedNotesFunc =  {( n:Set<Note> ) -> Void in }
        super.init(coder: aDecoder)
    }
    
    func addKey(note:Note){
        
        let newKey:KeyBase = KeyBase(note: note)
        keys.append(newKey)
        
        var keyFrame:CGRect = CGRectZero
        if note.isIvory {
            keyFrame.size.width = ivoryWidth
            keyFrame.size.height = ivoryHeight
            keyFrame.origin.x = ivoryWidth * CGFloat(self.keyRange.ivoryIndex(note)!)
        }else{
            keyFrame.size.width = ebonyWidth
            keyFrame.size.height = ebonyHeight
            keyFrame.origin.x = ( ivoryWidth * CGFloat(self.keyRange.ivoryIndex(note)!) ) - (ebonyWidth/2)
        }
        newKey.frame = keyFrame
        
        newKey.highlighted = false
        newKey.userInteractionEnabled = false
        
        self.addSubview(newKey)
        if note.isIvory {
            self.sendSubviewToBack(newKey)
        }
    }
    
    func removeAllKeysFromView(){
        for view:UIView in self.subviews {
            view.removeFromSuperview()
        }
        self.keys.removeAll(keepCapacity: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.removeAllKeysFromView()
        
        ivoryWidth = self.frame.size.width / CGFloat(self.keyRange.numIvoryKeys)
        ivoryHeight = self.frame.size.height
        ebonyWidth = ivoryWidth * ivoryToEbonyWidth
        ebonyHeight = ivoryHeight * ivoryToEbonyHeight
        
        for note in self.keyRange.notes {
            self.addKey(note)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var pressedNotes:Set<Note> = Set<Note>()
        for keyIndex in 0 ... self.keys.count-1 {
            let key:KeyBase = self.keys[keyIndex]
            var keyIsPressed:Bool = false
            for touch:UITouch in touches {
                let location:CGPoint = touch.locationInView(self)
                if CGRectContainsPoint(key.frame, location) {
                    var ignore:Bool = false
                    if key.note.isIvory {
                        if keyIndex > 0 {
                            let previousKey:KeyBase = self.keys[keyIndex-1]
                            if (!previousKey.note.isIvory &&
                                CGRectContainsPoint(previousKey.frame, location)){
                                    ignore = true
                            }
                        }
                        if keyIndex < self.keys.count-1 {
                            let nextKey:KeyBase = self.keys[keyIndex+1]
                            if(!nextKey.note.isIvory &&
                                CGRectContainsPoint(nextKey.frame, location)){
                                    ignore = true
                            }
                        }
                    }
                    
                    if ignore == false {
                        keyIsPressed = true
                        if !key.highlighted {
                            key.highlighted = true
                            pressedNotes.insert(key.note)
                        }
                    }
                }
            }
            if keyIsPressed == false && key.highlighted{
                key.highlighted = false
            }
        }
        
        self.pressedNotesFunc(pressedNotes)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.touchesMoved(touches, withEvent: event)
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for keyImage:UIImageView in keys {
            for touch:UITouch in touches {
                let location:CGPoint = touch.locationInView(self)
                if CGRectContainsPoint(keyImage.frame, location) {
                    if (touch.phase == UITouchPhase.Ended ||
                        touch.phase == UITouchPhase.Cancelled){
                            keyImage.highlighted = false
                    }
                }
            }
        }
    }
}