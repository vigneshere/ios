//
//  FaceView.swift
//  FaceIt
//
//  Created by Vignesh Saravanai on 07/05/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit

@IBDesignable
class FaceView: UIView {
    
    @IBInspectable var scale: CGFloat = 0.90 { didSet { setNeedsDisplay() } }
    @IBInspectable var mouthCurvature: Double = 1.0 { didSet { setNeedsDisplay() } }
    @IBInspectable var eyesOpen: Bool = true { didSet { setNeedsDisplay() } }
    @IBInspectable var eyeBrowTilt: Double = 0.0 { didSet { setNeedsDisplay() } }
    @IBInspectable var color: UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    @IBInspectable var lineWidth:CGFloat = 5.0 { didSet { setNeedsDisplay() } }
    
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Changed, .Ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    private var faceRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    private var faceCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private struct Ratios {
        static let RadiusToEyeOffset: CGFloat = 3
        static let RadiusToEyeRadius: CGFloat = 10
        static let RadiusToMouthWidth: CGFloat = 1
        static let RadiusToMouthHeight: CGFloat = 3
        static let RadiusToMouthOffset: CGFloat = 3
    }
    
    private enum Eye {
        case Left
        case Right
    }
    
    private func pathForCircle(midPoint: CGPoint, withRadius radius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath(arcCenter: midPoint, radius: radius, startAngle: 0.0, endAngle: CGFloat(2 * M_PI), clockwise: false)
        path.lineWidth = 5.0
        return path
    }
    
    private func getEyeCenter(eye: Eye) -> CGPoint {
        let eyeOffSet = faceRadius / Ratios.RadiusToEyeOffset
        var eyeCenter = faceCenter
        eyeCenter.y -= eyeOffSet
        switch eye {
        case .Left: eyeCenter.x -= eyeOffSet
        case .Right: eyeCenter.x += eyeOffSet
        }
        return eyeCenter
    }
    
    private func pathForEye(eye: Eye) -> UIBezierPath {
        let eyeRadius = faceRadius / Ratios.RadiusToEyeRadius
        let eyeCenter = getEyeCenter(eye)
        if (eyesOpen) {
            return pathForCircle(eyeCenter, withRadius: eyeRadius)
        }
        let path = UIBezierPath()
        path.moveToPoint( CGPoint(x:eyeCenter.x - eyeRadius, y:eyeCenter.y) )
        path.addLineToPoint(CGPoint(x:eyeCenter.x + eyeRadius, y:eyeCenter.y))
        path.lineWidth = lineWidth
        return path
    }
    
    private func pathForMouth() -> UIBezierPath {
        let mouthWidth = faceRadius / Ratios.RadiusToMouthWidth
        let mouthHeight = faceRadius / Ratios.RadiusToMouthHeight
        let mouthOffset = faceRadius / Ratios.RadiusToMouthOffset
        let mouthRect = CGRect(x: faceCenter.x - mouthWidth/2, y: faceCenter.y + mouthOffset, width: mouthWidth, height: mouthHeight)
        let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.minY)
        let end = CGPoint(x: mouthRect.maxX, y: mouthRect.minY)
        let cp1 = CGPoint(x: mouthRect.minX + mouthRect.width / 3, y: mouthRect.minY + smileOffset)
        let cp2 = CGPoint(x: mouthRect.maxX - mouthRect.width / 3, y: mouthRect.minY + smileOffset)
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
    }
    
    override func drawRect(rect: CGRect) {
        color.set()
        pathForCircle(faceCenter, withRadius: faceRadius).stroke()
        pathForEye(.Left).stroke()
        pathForEye(.Right).stroke()
        pathForMouth().stroke()
    }
    
}
