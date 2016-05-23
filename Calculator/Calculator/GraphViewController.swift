//
//  GraphViewController.swift
//  Calculator
//
//  Created by Vignesh Saravanai on 19/05/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    var function : ((Double) -> Double)?
    var label : String?
    
    //Tap recognizer action callback
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .Ended: graphView.origin = recognizer.locationInView(self.view)
        default: break
        }
    }
    
    //Pan recognizer action callback
    func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Ended,.Changed: graphView.origin = recognizer.locationInView(self.view)
        default: break
        }
    }
    
    @IBOutlet weak var graphView: GraphUIView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: graphView, action: #selector(GraphUIView.changeScale(_:))
            ))
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(
                target: self, action: #selector(GraphViewController.handlePan(_:))
            ))
        }
    }
    
    override func viewDidLoad() {
        graphView.graphFunc = function
        graphView.label = label
    }
}
