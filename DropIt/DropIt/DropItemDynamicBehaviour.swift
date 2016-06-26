//
//  DropItemDynamicBehaviour.swift
//  DropIt
//
//  Created by Vignesh Saravanai on 25/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit

class DropItemDynamicBehaviour : UIDynamicBehavior {
    
    var gravity = UIGravityBehavior()
    
    var collider : UICollisionBehavior = {
        let collider = UICollisionBehavior()
        collider.translatesReferenceBoundsIntoBoundary = true
        return collider
    }()
    
    var itemBehavior : UIDynamicItemBehavior = {
        let ib = UIDynamicItemBehavior()
        ib.allowsRotation = false
        ib.elasticity = 0.75
        return ib
    }()
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(itemBehavior)
    }
    
    func addItem(item : UIDynamicItem) {
        gravity.addItem(item)
        collider.addItem(item)
        itemBehavior.addItem(item)
    }
    
    func removeItem(item: UIDynamicItem) {
        gravity.removeItem(item)
        collider.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    func addBarrier(path: UIBezierPath, named name: String) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
}