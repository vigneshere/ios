//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Vignesh Saravanai on 26/04/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    
    func setOperand(operand: Double) {
        if pendingBinaryOperationInfo.status == false {
            internalState.removeAll()
        }
        internalState.append(operand)
        accumulator = operand
    }
    
    private enum Operation {
        case Constant(Double)
        case ConstOperation(() -> Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    private var operations : Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "℮" : Operation.Constant(M_E),
        "R" : Operation.ConstOperation({ drand48() } ),
        "±" : Operation.UnaryOperation( { -$0 } ),
        "√" : Operation.UnaryOperation( { sqrt($0) }  ),
        "×" : Operation.BinaryOperation( { $0 * $1 } ),
        "−" : Operation.BinaryOperation( { $0 - $1 } ),
        "+" : Operation.BinaryOperation( { $0 + $1 } ),
        "÷" : Operation.BinaryOperation( { $0 / $1 } ),
        "%" : Operation.BinaryOperation( { $0 % $1 } ),
        "X^Y" : Operation.BinaryOperation( { pow($0 , $1) }  ),
        "=" : Operation.Equals
    ]
    
    func clear() {
        pendingBinaryOperationInfo.status = false
        accumulator = 0.0
        internalState.removeAll()
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
           //user changed his mind and tries different binaryOperator now
           if pendingBinaryOperationInfo.status == true,
                let prevSymbol = internalState.last as? String,
                let prevOperation = operations[prevSymbol] {
                switch prevOperation {
                case .BinaryOperation:
                    pendingBinaryOperationInfo.status = false
                    internalState.removeLast()
                default:break
                }
            }
            
            internalState.append(symbol)
            switch operation {
            case .Constant(let value): accumulator = value
            case .UnaryOperation(let function): accumulator = function(accumulator)
            case .BinaryOperation(let function):
                performBinaryOperation()
                pendingBinaryOperationInfo = PendingBinaryOperationInfo(status:true, firstOperand: accumulator, binaryFunction: function)
            case .Equals: performBinaryOperation()
            case .ConstOperation(let function): accumulator = function()
            }
            
        }
    }
    
    typealias PropertyList = AnyObject
    
    var description : String {
        get {
            var updatedState : [String] = [String]()
            let numberFormatter = NSNumberFormatter()
            numberFormatter.alwaysShowsDecimalSeparator = false
            var applyUnaryOnResult : Bool = false
            for op in internalState {
                if let operand = op as? Double {
                    applyUnaryOnResult = false
                    updatedState.append(numberFormatter.stringFromNumber(operand)!)
                }
                else if let symbol = op as? String {
                    if let operation = operations[symbol] {
                        switch operation {
                        case .Equals:
                            applyUnaryOnResult = true
                        case .UnaryOperation:
                            updatedState.insert(symbol + "(", atIndex:
                                (applyUnaryOnResult ? 0 : (updatedState.count - 1)))
                            updatedState.append(")")
                            applyUnaryOnResult = true
                        default:
                            updatedState.append(symbol)
                            applyUnaryOnResult = false
                        }
                    }
                }
                
            }
            return (updatedState.joinWithSeparator(" "))
        }
    }
    
    var savedState : PropertyList {
        get {
            return internalState
        }
        set {
            let oldBinaryOpInfo = pendingBinaryOperationInfo
            clear()
            if let ops = newValue as? [AnyObject] {
                for op in ops {
                    if let operand = op as? Double {
                        setOperand(operand)
                    }
                    else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
            pendingBinaryOperationInfo = oldBinaryOpInfo
        }
    }
    
    private var internalState = [PropertyList]()
    
    private func performBinaryOperation() {
        if pendingBinaryOperationInfo.status == true {
            accumulator = pendingBinaryOperationInfo.binaryFunction(pendingBinaryOperationInfo.firstOperand, accumulator)
            pendingBinaryOperationInfo.status = false
        }
    }
    
    var isPartialResult : Bool {
        get {
            return pendingBinaryOperationInfo.status
        }
    }

    private var pendingBinaryOperationInfo = PendingBinaryOperationInfo(status: false, firstOperand: 0.0, binaryFunction: { $0 + $1 } )
    private struct PendingBinaryOperationInfo {
        var status : Bool
        var firstOperand : Double
        var binaryFunction : (Double, Double) -> Double
    }
    
    var result : Double {
        get {
            return accumulator
        }
    }
}