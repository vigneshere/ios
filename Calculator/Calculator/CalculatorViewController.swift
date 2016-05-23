//
//  ViewController.swift
//  Calculator
//
//  Created by Vignesh Saravanai on 23/04/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved./Users/svignesh/Downloads/AppIconResizer_201605062329_067b80440f63878dd3dad61b955b85d0/Icon-60@2x.png
//

import UIKit

class CalculatorViewController: UIViewController {
    
    private var userTyping = false
    
    private var brain = CalculatorBrain()
    
    private let numberFormatter = NSNumberFormatter()
    
    private var displayOutputValue: Double {
        get {
            return Double(displayOutput.text!)!
        }
        set {
            displayOutput.text = String(newValue)
        }
    }
    
    //utility func
    private func syncDisplayWithBrain() {
        userTyping = false
        displayOutput.text = numberFormatter.stringFromNumber(brain.result)
        inputHistory.text = brain.description + (brain.isPartialResult ? " ..." : " ")
        if (inputHistory.text!.isEmpty) {
            inputHistory.text = " "
        }
    }
    
    // outlets
    @IBOutlet weak var inputHistory: UILabel!
    
    @IBOutlet private weak var displayOutput: UILabel!
    
    // actions
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        let currentDisplay = userTyping ? (displayOutput.text! + digit) : digit
        if currentDisplay == "." || Double(currentDisplay) != nil  {
            displayOutput.text = currentDisplay
        }
        userTyping = true
    }
    
    @IBAction func save() {
        brain.variableValues["M"] = displayOutputValue
        if userTyping {
            brain.runProgram()
        }
        else {
            brain.performUndoOperation()
        }
        syncDisplayWithBrain()
    }
    
    @IBAction func retrieve() {
        brain.setOperand("M")
        displayOutput.text = numberFormatter.stringFromNumber(brain.result)
    }
    
    @IBAction private func clear(sender: UIButton) {
        //savedState = nil
        brain.clear()
        syncDisplayWithBrain()
    }
    
  
    @IBAction private func backspace() {
        if let str = displayOutput.text where
            (str.characters.count > 0 && userTyping) {
            let index = str.startIndex.advancedBy(str.characters.count - 1)
            displayOutput.text = str.substringToIndex(index)
            if (displayOutput.text!.isEmpty) {
                displayOutput.text = "0"
                userTyping = false
            }
        }
        else {
            brain.performUndoOperation()
            syncDisplayWithBrain()
        }
    }
    
    
    @IBAction private func performOperation(sender: UIButton) {
        if userTyping {
            brain.setOperand(displayOutputValue)
        }
        
        if let symbol = sender.currentTitle {
            brain.performOperation(symbol)
        }
        
        syncDisplayWithBrain()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "showGraph" {
            return !brain.isPartialResult && (brain.result != 0.0)
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showGraph" {
            print("showGraph prepareForSegue")
            if let graphVC = segue.destinationViewController as? GraphViewController {
                print("setting graph func in prepareForSegue \(brain.description)")
                graphVC.function = graphFunc
                graphVC.label = brain.description
            }
        }
    }
    
    func graphFunc(x: Double) -> Double {
        if let prevM = brain.variableValues["M"] {
            brain.variableValues["M"] = x
            brain.runProgram()
            brain.variableValues["M"] = prevM
        }
        return brain.result
    }
    
    // inherited public functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberFormatter.maximumFractionDigits = 6
        numberFormatter.alwaysShowsDecimalSeparator = false
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

