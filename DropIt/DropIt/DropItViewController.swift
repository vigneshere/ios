//
//  DropItViewController.swift
//  DropIt
//
//  Created by Vignesh Saravanai on 25/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit

class DropItViewController: UIViewController {

    @IBOutlet weak var gameView: DropItView! {
        didSet {
            gameView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(dropBy(_:))))
            gameView.addGestureRecognizer(
                UIPanGestureRecognizer(target: gameView, action: #selector(DropItView.grapDrop(_:))))
            gameView.realGravity = true
        }
    }
    
    func dropBy(recognizer: UIGestureRecognizer) {
        gameView.addDrop()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        gameView.animating = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        gameView.animating = false
    }
}
