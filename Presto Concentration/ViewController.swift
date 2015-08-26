//
//  ViewController.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/19/15.
//  Copyright (c) 2015 Anthony Gabriele. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    
    @IBOutlet var skViewOp:SKView?
    @IBOutlet var keyboardView:KeyboardView?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let skView = skViewOp!
        let testFrame = skView.frame
        let scene = AnimatedStaff(size: skView.bounds.size)
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
        
        //keyboard
        self.keyboardView?.pressedNotesFunc = scene.notesPressed
    }
    

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}