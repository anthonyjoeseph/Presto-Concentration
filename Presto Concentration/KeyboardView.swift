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
    
    var pressedPitchesFunc: (Set<Pitch>) -> Void

    required init?(coder aDecoder: NSCoder) {
        self.keyRange = KeyRange(lowPitch: Pitch(absolutePitch: 0), highPitch: Pitch(absolutePitch: 0))
        //empty, client can override
        self.pressedPitchesFunc =  {( n:Set<Pitch> ) -> Void in }
        super.init(coder: aDecoder)
    }
    
    func addKey(pitch:Pitch){
        
        let newKey:KeyBase = KeyBase(pitch: pitch)
        keys.append(newKey)
        
        var keyFrame:CGRect = CGRectZero
        if Keyboard.isIvory(pitch) {
            keyFrame.size.width = ivoryWidth
            keyFrame.size.height = ivoryHeight
            keyFrame.origin.x = ivoryWidth * CGFloat(self.keyRange.ivoryIndex(pitch)!)
        }else{
            keyFrame.size.width = ebonyWidth
            keyFrame.size.height = ebonyHeight
            keyFrame.origin.x = ( ivoryWidth * CGFloat(self.keyRange.ivoryIndex(pitch)!) ) - (ebonyWidth/2)
        }
        newKey.frame = keyFrame
        
        newKey.highlighted = false
        newKey.userInteractionEnabled = false
        
        self.addSubview(newKey)
        if Keyboard.isIvory(pitch) {
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
        
        for pitch in self.keyRange.pitches {
            self.addKey(pitch)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var pressedPitches:Set<Pitch> = Set<Pitch>()
        for keyIndex in 0 ... self.keys.count-1 {
            let key:KeyBase = self.keys[keyIndex]
            var keyIsPressed:Bool = false
            for touch:UITouch in touches {
                let location:CGPoint = touch.locationInView(self)
                if CGRectContainsPoint(key.frame, location) {
                    var ignore:Bool = false
                    if Keyboard.isIvory(key.pitch) {
                        if keyIndex > 0 {
                            let previousKey:KeyBase = self.keys[keyIndex-1]
                            if (!Keyboard.isIvory(previousKey.pitch) &&
                                CGRectContainsPoint(previousKey.frame, location)){
                                    ignore = true
                            }
                        }
                        if keyIndex < self.keys.count-1 {
                            let nextKey:KeyBase = self.keys[keyIndex+1]
                            if(!Keyboard.isIvory(nextKey.pitch) &&
                                CGRectContainsPoint(nextKey.frame, location)){
                                    ignore = true
                            }
                        }
                    }
                    
                    if ignore == false {
                        keyIsPressed = true
                        if !key.highlighted {
                            key.highlighted = true
                            pressedPitches.insert(key.pitch)
                        }
                    }
                }
            }
            if keyIsPressed == false && key.highlighted{
                key.highlighted = false
            }
        }
        
        self.pressedPitchesFunc(pressedPitches)
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