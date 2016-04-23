//
//  ViewController.swift
//  Calculator
//
//  Created by Vignesh Saravanai on 23/04/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit

func add( text1: String, text2: String) -> String {
    return String(Int(text1)! + Int(text2)!)
}

func subtract( text1: String, text2: String) -> String {
    return String(Int(text1)! - Int(text2)!)
}

func multiply( text1: String, text2: String) -> String {
    return String(Int(text1)! * Int(text2)!)
}

func divide( text1: String, text2: String) -> String {
    return String(Int(text1)! / Int(text2)!)
}

func doMathOperation( text1: String, text2: String, symbol: String) -> String {
    switch symbol {
    case "+" :
        return add(text1, text2: text2)
    case "-" :
        return subtract(text1, text2: text2)
    case "*" :
        return multiply(text1, text2: text2)
    case "/" :
        return divide(text1, text2: text2)
    default:
        break;
        
    }
    return String("");
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var displayOutput: UILabel!
    
    var userTyping = false
    var previousValue:String?
    var currentValue:String?
    var operationSelected:String?
   
    @IBAction func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        displayOutput.text = userTyping ? (displayOutput.text! + digit) : digit
        currentValue = displayOutput.text
        userTyping = true
    }
    
    @IBAction func Pi(sender: UIButton) {
        userTyping = false
        displayOutput.text = String(M_PI)
        currentValue = displayOutput.text
    }
    
    @IBAction func clearPanel(sender: UIButton) {
        displayOutput.text = "0"
        userTyping = false
        previousValue = nil
        currentValue = nil
        operationSelected = nil
    }
    
    @IBAction func performOperation(sender: UIButton) {
        userTyping = false
        
        if let mathSymbol = sender.currentTitle {
            
            // empty state
            if currentValue == nil && previousValue == nil {
                return
            }
            
            // get the operation
            let prevOperation = operationSelected
            operationSelected = mathSymbol
            
            // no input yet, operation noted, just skip
            if currentValue == nil {
                return
            }
            
            // no operation stored previously, swap prev/current
            if prevOperation == nil  {
                previousValue = currentValue
                currentValue = nil
                return
            }
            
            // perform operation and update
            let output = doMathOperation(previousValue!, text2: currentValue!, symbol: prevOperation!)
            displayOutput.text = output
            
            // nothing to remember for "=" operator
            if mathSymbol == "=" {
                currentValue = output
                previousValue = nil
                operationSelected = nil
                return
            }
            
            previousValue = output
            currentValue = nil
        }
    }
   
    
}

