//
//  ViewController.swift
//  FaceIt
//
//  Created by Vignesh Saravanai on 07/05/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController {

    var face = FaceModel() {
        didSet {
            drawFace()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var faceView: FaceView! {
        didSet {
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: faceView, action: #selector(FaceView.changeScale(_:))
            ))
            let happyGestureRec = UISwipeGestureRecognizer(target: self, action: #selector(FaceViewController.handleHappyGesture(_:)))
            happyGestureRec.direction = UISwipeGestureRecognizerDirection.Down
            faceView.addGestureRecognizer(happyGestureRec)
            let sadGestureRec = UISwipeGestureRecognizer(target: self, action: #selector(FaceViewController.handleSadGesture(_:)))
            sadGestureRec.direction = UISwipeGestureRecognizerDirection.Up
            faceView.addGestureRecognizer(sadGestureRec)
            drawFace()
        }
    }
    
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        switch face.eyes {
            case .Closed: face.eyes = .Opened
            case .Opened: face.eyes = .Closed
        }
    }
    
    func handleSadGesture(recognizer: UISwipeGestureRecognizer) {
        face.mouth = face.mouth.SadderFace()
        print("face.mouth \(face.mouth)")
    }
    
    func handleHappyGesture(recognizer: UISwipeGestureRecognizer) {
        face.mouth = face.mouth.HappierFace()
        print("face.mouth \(face.mouth)")
    }
    
    var mouthVariations = [
        FaceModel.Mouth.Happy: 1.0,
        FaceModel.Mouth.Neutral: 0.0,
        FaceModel.Mouth.Sad: -1.0
    ]
    
    func drawFace() {
        print("Inside drawFace")
        switch face.eyes {
        case .Closed: faceView.eyesOpen = false
        case .Opened: faceView.eyesOpen = true
        }
        faceView.mouthCurvature = mouthVariations[face.mouth] ?? 0.0
    }


}

