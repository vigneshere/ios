//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Vignesh Saravanai on 26/04/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    typealias PropertyList = AnyObject
    
    private enum Operation {
        case Constant(Double)
        case ConstOperation(() -> Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    private struct PendingBinaryOperationInfo {
        var status : Bool
        var firstOperand : Double
        var binaryFunction : (Double, Double) -> Double
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

    private let descNumberFormatter = NSNumberFormatter()
    
    private var accumulator = 0.0
    
    private var pendingBinaryOperationInfo = PendingBinaryOperationInfo(status: false, firstOperand: 0.0, binaryFunction: { $0 + $1 } )

    private var program = [PropertyList]()
    
    private func performBinaryOperation() {
        if pendingBinaryOperationInfo.status == true {
            accumulator = pendingBinaryOperationInfo.binaryFunction(pendingBinaryOperationInfo.firstOperand, accumulator)
            pendingBinaryOperationInfo.status = false
        }
    }
    
    
    // public interface
    
    var variableValues : Dictionary<String, Double> = [:]
    
    var isPartialResult : Bool {
        get {
            return pendingBinaryOperationInfo.status
        }
    }
    
    var result : Double {
        get {
            return accumulator
        }
    }
    
    var description : String {
        get {
            var updatedState = [String]()
            descNumberFormatter.alwaysShowsDecimalSeparator = false
            var applyUnaryOnResult : Bool = true
            for op in program {
                if let operand = op as? Double {
                    applyUnaryOnResult = false
                    updatedState.append(descNumberFormatter.stringFromNumber(operand)!)
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
                    else {
                        updatedState.append(symbol)
                    }
                }
                
            }
            return (updatedState.joinWithSeparator(" "))
        }
    }
    
    func setOperand(operand: Double) {
        program.append(operand)
        accumulator = operand
    }
    
    
    func setOperand(operand: String) {
        program.append(operand)
        accumulator = variableValues[operand] ?? 0.0
    }
    
    
    func clear() {
        pendingBinaryOperationInfo.status = false
        accumulator = 0.0
        program.removeAll()
        variableValues.removeAll()
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            //user changed his mind and tries different binaryOperator now
            if pendingBinaryOperationInfo.status == true,
                let prevSymbol = program.last as? String,
                let prevOperation = operations[prevSymbol] {
                switch prevOperation {
                case .BinaryOperation:
                    pendingBinaryOperationInfo.status = false
                    program.removeLast()
                default:break
                }
            }
            
            program.append(symbol)
            
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
    
    func performUndoOperation() {
        program.removeLast()
        runProgram()
    }
    
    func runProgram() {
        let brain = CalculatorBrain()
        brain.variableValues = variableValues
        for op in program {
            if let operand = op as? Double {
                brain.setOperand(operand)
            }
            else if let operation = op as? String {
                if operations[operation] != nil {
                    brain.performOperation(operation)
                }
                else {
                    brain.setOperand(operation)
                }
            }
        }
        pendingBinaryOperationInfo = brain.pendingBinaryOperationInfo
        accumulator = brain.result
    }
}