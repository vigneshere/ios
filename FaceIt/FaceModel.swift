//
//  FaceModel.swift
//  FaceIt
//
//  Created by Vignesh Saravanai on 08/05/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import Foundation

struct FaceModel {
    enum Eyes {
        case Closed
        case Opened
    }
    
    
    enum Mouth : Int {
        case Sad = 1
        case Neutral
        case Happy
        
        func HappierFace() -> Mouth {
            return Mouth(rawValue: (self.rawValue  + 1)) ?? Happy
        }
        
        func SadderFace() -> Mouth {
            return Mouth(rawValue: (self.rawValue - 1)) ?? Sad
        }
    }
    
    var eyes = Eyes.Closed
    var mouth = Mouth.Neutral
}
