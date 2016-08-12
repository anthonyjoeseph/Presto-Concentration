//
//  HighScoreViewController.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 1/11/16.
//  Copyright © 2016 Anthony Gabriele. All rights reserved.
//

import Foundation
import UIKit

class HighScoreViewController: UIViewController{
    
    @IBOutlet private var nameLabels:[UILabel]!
    @IBOutlet private var scoreLabels:[UILabel]!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //sort names and scores
        self.nameLabels.sortInPlace(
            {
                (label1:UILabel, label2:UILabel) -> Bool in
                    return label1.tag < label2.tag
            })
        self.scoreLabels.sortInPlace(
            {
                (label1:UILabel, label2:UILabel) -> Bool in
                    return label1.tag < label2.tag
            })
        
        let gameData = GamePersistence()
        let scores = gameData.highScores()!
        let names = gameData.scoreNames()!
        print(String(names.count))
        print(names.keys)
        for index in 0...scores.count-1{
            let currentScoreLabel = scoreLabels[index]
            let currentNameLabel = nameLabels[index]
            
            let currentScore = scores[index]
            let currentName = names[currentScore]
            
            currentScoreLabel.text = String(currentScore)
            currentNameLabel.text = currentName
        }
    }
}
