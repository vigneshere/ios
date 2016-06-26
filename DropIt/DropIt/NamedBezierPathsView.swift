//
//  NamedBezierPathsView.swift
//  DropIt
//
//  Created by Vignesh Saravanai on 26/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit

class NamedBezierPathsView: UIView {
    
    var bezierPaths = [String: UIBezierPath]() {   didSet { setNeedsDisplay()  } }
    
    override func drawRect(rect: CGRect) {
        for (_, path) in bezierPaths {
            path.stroke()
        }
    }
    

}
