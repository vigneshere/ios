//
//  ViewController.swift
//  Calculator
//
//  Created by Vignesh Saravanai on 23/04/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
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
    
    
    @IBOutlet weak var inputHistory: UILabel!
    @IBOutlet private weak var displayOutput: UILabel!
    
    private var displayOutputValue: Double {
        get {
            return Double(displayOutput.text!)!
        }
        set {
            displayOutput.text = String(newValue)
        }
    }
    
    var userTyping = false
    var brain = CalculatorBrain()
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        let currentDisplay = userTyping ? (displayOutput.text! + digit) : digit
        if currentDisplay == "." || Double(currentDisplay) != nil  {
            displayOutput.text = currentDisplay
        }
        userTyping = true
    }
    
    var savedState : CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        //savedState = brain.savedState
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
        //if savedState != nil {
        //    brain.savedState = savedState!
        //    displayOutputValue = brain.result
        //}
    }
    
    @IBAction private func clear(sender: UIButton) {
        //savedState = nil
        brain.clear()
        syncDisplayWithBrain()
    }
    
    private func syncDisplayWithBrain() {
        userTyping = false
        displayOutput.text = numberFormatter.stringFromNumber(brain.result)
        inputHistory.text = brain.description + (brain.isPartialResult ? " ..." : " ")
        if (inputHistory.text!.isEmpty) {
            inputHistory.text = " "
        }
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
    
    private let numberFormatter = NSNumberFormatter()
    
    @IBAction private func performOperation(sender: UIButton) {
        if userTyping {
            brain.setOperand(displayOutputValue)
        }
        
        if let symbol = sender.currentTitle {
            brain.performOperation(symbol)
        }
        
        syncDisplayWithBrain()
    }
    
}

