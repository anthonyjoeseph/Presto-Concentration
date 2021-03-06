//
//  KeyBase.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/26/15.
//  Copyright (c) 2015 Anthony Gabriele. All rights reserved.
//

import Foundation
import UIKit

class KeyBase: UIImageView{
    private static let ivoryImage:UIImage = UIImage(named: "ivory_key")!
    private static let ivoryPressedImage:UIImage = UIImage(named: "ivory_key_pressed")!
    private static let ebonyImage:UIImage = UIImage(named: "ebony_key")!
    private static let ebonyPressedImage:UIImage = UIImage(named: "ebony_key_pressed")!
    
    init(isIvory:Bool, pitchLetterOp:PitchLetter?) {
        if isIvory {
            super.init(image:KeyBase.ivoryImage)
            self.highlightedImage = KeyBase.ivoryPressedImage
        }else{
            super.init(image:KeyBase.ebonyImage)
            self.highlightedImage = KeyBase.ebonyPressedImage
        }
        
        if let pitchLetter = pitchLetterOp {
            let letterLabel:UILabel = UILabel()
            letterLabel.text = pitchLetter.rawValue
            letterLabel.font = UIFont.boldSystemFontOfSize(30)
            
            var labelFrame:CGRect = CGRect()
            labelFrame.size.width = self.frame.size.width * 0.65
            labelFrame.size.height = self.frame.size.width / 2
            labelFrame.origin.x = (self.frame.size.width / 2)
            labelFrame.origin.y = self.frame.size.height - labelFrame.size.height - 300
            letterLabel.frame = labelFrame
            
            self.addSubview(letterLabel)
            self.bringSubviewToFront(letterLabel)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}