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
    let note:Note
    
    private static let ivoryImage:UIImage = UIImage(named: "ivory_key")!
    private static let ivoryPressedImage:UIImage = UIImage(named: "ivory_key_pressed")!
    private static let ebonyImage:UIImage = UIImage(named: "ebony_key")!
    private static let ebonyPressedImage:UIImage = UIImage(named: "ebony_key_pressed")!
    
    init(note: Note) {
        self.note = note
        if self.note.isIvory {
            super.init(image:KeyBase.ivoryImage)
        }else{
            super.init(image:KeyBase.ebonyImage)
        }
    }

    required init(coder aDecoder: NSCoder) {
        self.note = Note(absoluteNote: 0)
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if(self.note.isIvory){
            self.highlightedImage = KeyBase.ivoryPressedImage
        }else{
            self.highlightedImage = KeyBase.ebonyPressedImage
        }
    }
}