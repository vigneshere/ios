//
//  DropItView.swift
//  DropIt
//
//  Created by Vignesh Saravanai on 25/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit
import CoreMotion

class DropItView: NamedBezierPathsView, UIDynamicAnimatorDelegate {
    
    private let dropsPerRow = 10
    private var dropSize : CGSize {
        let size = bounds.size.width/CGFloat(dropsPerRow)
        return CGSize(width: size, height: size)
    }

    func addDrop() {
        var frame = CGRect(origin: CGPoint.zero, size:dropSize)
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
        let drop = UIView(frame: frame)
        drop.backgroundColor = UIColor.random
        addSubview(drop)
        dropBehavior.addItem(drop)
        lastDrop = drop
    }
    
    private lazy var animator : UIDynamicAnimator = {
        
        let animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        return animator
    }()
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        removeCompletedRow()
    }
    
    var animating : Bool = false {
        didSet {
            if animating {
                animator.addBehavior(dropBehavior)
                updateRealGravity()
            }
            else {
                animator.removeBehavior(dropBehavior)
            }
        }
    }
    
    var dropBehavior = DropItemDynamicBehaviour()
    
    private func removeCompletedRow() {
        var dropsToRemove = [UIView]()
        var hitTestRect = CGRect(origin: bounds.lowerLeft, size: dropSize)
        repeat {
            hitTestRect.origin.x = bounds.minX
            hitTestRect.origin.y -= dropSize.height
            var dropsFound = [UIView]()
            while hitTestRect.origin.x <= bounds.maxX {
                if let hitView = hitTest(hitTestRect.mid) where hitView.superview == self {
                    dropsFound.append(hitView)
                }
                else {
                    break
                }
                hitTestRect.origin.x += dropSize.width
            }
            if dropsFound.count == dropsPerRow {
                dropsToRemove += dropsFound
            }
        } while dropsToRemove.count == 0 && hitTestRect.origin.y > bounds.minY
        
        for drop in dropsToRemove {
            dropBehavior.removeItem(drop)
            drop.removeFromSuperview()
        }
    }
    
    private struct PathNames {
        static let MiddleBarrier = "Middle Barrier"
        static let Attachment = "Attachment"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(ovalInRect: CGRect(center: bounds.mid, size: dropSize))
        dropBehavior.addBarrier(path, named: PathNames.MiddleBarrier)
        bezierPaths[PathNames.MiddleBarrier] = path
    }
    
    private var attachment: UIAttachmentBehavior? {
        willSet {
            if attachment != nil {
                animator.removeBehavior(attachment!)
                self.bezierPaths[PathNames.Attachment] = nil
            }
        }
        didSet {
            if attachment != nil {
                animator.addBehavior(attachment!)
                attachment!.action = { [unowned self] in
                    if let attachedDrop = self.attachment!.items.first {
                        self.bezierPaths[PathNames.Attachment] = UIBezierPath.lineFrom(self.attachment!.anchorPoint, to: attachedDrop.center)
                    }
                }
            }
        }
    }
    
    private var lastDrop: UIView?
    
    func grapDrop(recognizer: UIPanGestureRecognizer) {
        let gesturePoint = recognizer.locationInView(self)
        switch recognizer.state {
        case .Began:
            if let dropAttach = lastDrop where dropAttach.superview != nil {
                attachment = UIAttachmentBehavior(item: dropAttach, attachedToAnchor: gesturePoint)
            }
            lastDrop = nil
        case .Changed:
            attachment?.anchorPoint = gesturePoint
        default:
            attachment = nil
        }
    }
    
    var realGravity: Bool = false {
        didSet {
            updateRealGravity()
        }
    }
    
    private var motionManager = CMMotionManager()
    
    private func updateRealGravity() {
        if realGravity {
            if motionManager.accelerometerAvailable && !motionManager.accelerometerActive {
                motionManager.accelerometerUpdateInterval = 0.25
                motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) { [unowned self] (data, error) in
                    if self.dropBehavior.dynamicAnimator != nil {
                        if var dx = data?.acceleration.x, var dy = data?.acceleration.y {
                            switch UIDevice.currentDevice().orientation {
                            case .Portrait: dy = -dy
                            case .PortraitUpsideDown: break
                            case .LandscapeRight: swap(&dx, &dy)
                            case .LandscapeLeft: swap(&dx, &dy); dy = -dy
                            default: dx = 0; dy = 0
                            }
                            self.dropBehavior.gravity.gravityDirection = CGVector(dx: dx, dy: dy)
                        }
                    }
                    else {
                        self.motionManager.stopAccelerometerUpdates()
                    }
                }

            }
        }
        else {
            motionManager.stopAccelerometerUpdates()
        }
    }
    
}

extension CGFloat {
    static func random(max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}

extension UIColor {
    class var random: UIColor {
        switch arc4random()%5 {
        case 0: return UIColor.greenColor()
        case 1: return UIColor.blueColor()
        case 2: return UIColor.orangeColor()
        case 3: return UIColor.redColor()
        case 4: return UIColor.purpleColor()
        default: return UIColor.blackColor()
        }
    }
}

extension CGRect {
    var mid: CGPoint { return CGPoint(x:midX, y: midY) }
    var upperLeft: CGPoint { return CGPoint(x:minX, y: minY) }
    var lowerLeft: CGPoint { return CGPoint(x:minX, y: maxY) }
    var upperRight: CGPoint { return CGPoint(x:maxX, y: minY) }
    var lowerRight: CGPoint { return CGPoint(x:maxX, y: maxY) }
    
    init(center: CGPoint, size: CGSize) {
        let upperLeft = CGPoint(x: center.x-size.width/2, y: center.y-size.height/2)
        self.init(origin: upperLeft, size: size)
    }
}

extension UIView {
    func hitTest(p: CGPoint) -> UIView? {
        return hitTest(p, withEvent:nil)
    }
}

extension UIBezierPath {
    class func lineFrom(from: CGPoint, to: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(from)
        path.addLineToPoint(to)
        return path
    }
}

