//
//  FaceModel.swift
//  FaceIt
//
//  Created by Vignesh Saravanai on 08/05/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import Foundation

class FaceModel {
    enum Eyes {
        case Closed
        case Opened
    }
    enum Mouth : Int {
        case Sad = 1
        case Netrual
        case Happy
        
        func HappierFace() -> Mouth {
            return Mouth(self + 1) ?? Happy
        }
        
        func SadderFace() -> Mouth {
            return Mouth(self - 1) ?? Sad
        }
        
    }
}