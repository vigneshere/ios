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
    
    //inspectable vars
    @IBInspectable private var scale : CGFloat = 1 { didSet { setNeedsDisplay() } }
    @IBInspectable private var axesColor : UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    @IBInspectable private var graphColor : UIColor = UIColor.brownColor() { didSet { setNeedsDisplay() } }
    @IBInspectable private var labelColor : UIColor = UIColor.redColor() { didSet { setNeedsDisplay() } }
 
    //computed properties
    private var pointsPerUnit : CGFloat { return 100 * scale }
    private var defaultOrigin : CGPoint { return CGPoint(x:bounds.midX, y:bounds.midY) }

    //private
    private var axesDrawer = AxesDrawer()
    
    //utility function to compute X point
    private func getX(boundsX: Int, originX: CGFloat) -> Double {
        return Double((CGFloat(boundsX) - originX) / pointsPerUnit)
    }
    
    //utility function to compute location Y
    private func getBoundsY(y: Double, originY: CGFloat) -> CGFloat {
        return originY - round(CGFloat(y) * pointsPerUnit)
    }
    
    //private helper functions for drawing
    private func drawAxesWith(origin: CGPoint) {
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.color = axesColor
        axesDrawer.drawAxesInRect(bounds, origin: origin, pointsPerUnit: pointsPerUnit)
    }
    
    private func drawGraphWith(origin: CGPoint) {
        guard let gFunc = graphFunc else {
            return
        }
        CGContextSaveGState(UIGraphicsGetCurrentContext())
        graphColor.set()
        let path = UIBezierPath()
        
        //iterate over the bounds and calculate y correspoinding to each x using graphFunc
        for boundsX in Int(bounds.minX)...Int(bounds.maxX) {
            let x = getX(boundsX, originX: origin.x)
            let y = gFunc(x)
            let cp = CGPoint(x: CGFloat(boundsX), y:getBoundsY(y, originY: origin.y))
            // check if point is within bounds
            if CGRectContainsPoint(bounds, cp) {
                path.empty ? path.moveToPoint(cp) : path.addLineToPoint(cp)
            }
        }
        path.stroke()
        CGContextRestoreGState(UIGraphicsGetCurrentContext())
    }
    
    private func drawAnchoredLabelAt(location: CGPoint) {
        guard let gLabel = label else {
            return
        }
        let attributes = [
            NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote),
            NSForegroundColorAttributeName : labelColor
        ]
        let textRect = CGRect(center: location, size: gLabel.sizeWithAttributes(attributes))
        gLabel.drawInRect(textRect, withAttributes: attributes)
    }

    //pulic vars: view parameters set by controller
    var origin : CGPoint? { didSet { setNeedsDisplay() } }
    var graphFunc : ((Double) -> Double)? { didSet { setNeedsDisplay() } }
    var label : String? { didSet { setNeedsDisplay() } }

    //Pinch recognizer action callback
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Changed, .Ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
    }
    
    override func drawRect(rect: CGRect) {
        let originToUse = origin ?? defaultOrigin
        drawAxesWith(originToUse)
        drawGraphWith(originToUse)
        drawAnchoredLabelAt(CGPoint(x: defaultOrigin.x/2, y: defaultOrigin.y/2))
    }
}
