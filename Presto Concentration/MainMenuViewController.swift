//
//  MainMenuViewController.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 12/29/15.
//  Copyright © 2015 Anthony Gabriele. All rights reserved.
//

import UIKit
import SpriteKit

class MainMenuViewController: UIViewController{
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let newViewController = segue.destinationViewController as? GameViewController {
            if segue.identifier == "Beginner"{
                newViewController.difficultyLevel = DifficultyLevel.Beginner
            }else if segue.identifier == "Intermediate" {
                newViewController.difficultyLevel = DifficultyLevel.Intermediate
            }else if segue.identifier == "Expert"{
                newViewController.difficultyLevel = DifficultyLevel.Expert
            }
        }
    }
}