//
//  GraphUIView.swift
//  Calculator
//
//  Created by Vignesh Saravanai on 19/05/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit

@IBDesignable
class GraphUIView: UIView {
    
    @IBInspectable var scale : CGFloat = 1 { didSet { setNeedsDisplay() } }
    @IBInspectable var color : UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    @IBInspectable var origin : CGPoint? { didSet { setNeedsDisplay() } }
    
    var graphFunc : ((Double) -> Double)? { didSet { setNeedsDisplay() } }
    var label : String? { didSet { setNeedsDisplay() } }
    
    var pointsPerUnit : CGFloat {
        return 25 * scale
    }
    
    var defaultOrigin : CGPoint {
        return CGPoint(x:bounds.midX, y:bounds.midY)
    }

    private var axesDrawer = AxesDrawer()
    
    private func getX(boundsX: Int, originX: CGFloat) -> Double {
        return Double((CGFloat(boundsX) - originX) / pointsPerUnit)
    }
    
    private func getBoundsY(y: Double, originY: CGFloat) -> CGFloat {
        return originY - round(CGFloat(y) * pointsPerUnit)
    }
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Changed, .Ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
    }
    
    func drawAxesWith(origin: CGPoint) {
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.color = color
        axesDrawer.drawAxesInRect(bounds, origin: origin, pointsPerUnit: pointsPerUnit)
    }
    
    func drawGraphWith(origin: CGPoint) {
        guard graphFunc != nil else {
            return
        }
        CGContextSaveGState(UIGraphicsGetCurrentContext())
        color.set()
        let path = UIBezierPath()
        for boundsX in Int(bounds.minX)...Int(bounds.maxX) {
            let x = getX(boundsX, originX: origin.x)
            let y = graphFunc!(x)
            let cp = CGPoint(x: CGFloat(boundsX), y:getBoundsY(y, originY: origin.y))
            if CGRectContainsPoint(bounds, cp) {
                path.empty ? path.moveToPoint(cp) : path.addLineToPoint(cp)
            }
        }
        path.stroke()
        CGContextRestoreGState(UIGraphicsGetCurrentContext())
    }
    
    func drawAnchoredLabelAt(location: CGPoint) {
        guard label != nil else {
            return
        }
        let attributes = [
            NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote),
            NSForegroundColorAttributeName : color
        ]
        let textRect = CGRect(center: location, size: label!.sizeWithAttributes(attributes))
        label!.drawInRect(textRect, withAttributes: attributes)
    }

    override func drawRect(rect: CGRect) {
        let originToUse = origin ?? defaultOrigin
        drawAxesWith(originToUse)
        drawGraphWith(originToUse)
        drawAnchoredLabelAt(CGPoint(x: defaultOrigin.x/2, y: defaultOrigin.y/2))
    }
}
