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
        
        var isConstant: Bool {
            if case Constant = self {
                return true
            }
            return false
        }
        
        var isUnaryOp: Bool {
            if case UnaryOperation = self {
                return true
            }
            return false
        }
        
        var isBinaryOp: Bool {
            if case BinaryOperation = self {
                return true
            }
            return false
        }
        
        var isEquals: Bool {
            if case Equals = self {
                return true
            }
            return false
        }
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
    
    private var descriptionState = [String]()
    
    private func performBinaryOperation() {
        if pendingBinaryOperationInfo.status {
            accumulator = pendingBinaryOperationInfo.binaryFunction(pendingBinaryOperationInfo.firstOperand, accumulator)
            pendingBinaryOperationInfo.status = false
        }
    }
    
    
    // public interface
    
    var variableValues : Dictionary<String, Double> = [:]
    
    var isPartialResult : Bool {
        return pendingBinaryOperationInfo.status
    }
    
    var result : Double {
        return accumulator
    }
    
    var description : String {
        return descriptionState.joinWithSeparator(" ")
    }
    
    func setOperand(operand: Double) {
        program.append(operand)
        descNumberFormatter.alwaysShowsDecimalSeparator = false
        descriptionState.append(descNumberFormatter.stringFromNumber(operand)!)
        accumulator = operand
    }
    
    func setOperand(operand: String) {
        program.append(operand)
        descriptionState.append(operand)
        accumulator = variableValues[operand] ?? 0.0
    }
    
    func clear() {
        pendingBinaryOperationInfo.status = false
        accumulator = 0.0
        program.removeAll()
        descriptionState.removeAll()
        variableValues.removeAll()
    }
    
    func performOperation(symbol: String) {
        guard let operation = operations[symbol] else {
            return
        }
        
        var wrapUnaryOnResult = false
        if let prevSymbol = program.last as? String, prevOperation = operations[prevSymbol] {
            //user changed his mind and tries different Operator now
            if prevOperation.isBinaryOp && !operation.isConstant {
                pendingBinaryOperationInfo.status = false
                program.removeLast()
            }
            if prevOperation.isEquals || prevOperation.isUnaryOp {
                wrapUnaryOnResult = true
            }
        }
        
        // update description
        if operation.isUnaryOp {
            descriptionState.insert(symbol + "(", atIndex:(wrapUnaryOnResult ? 0 : (descriptionState.count - 1)))
            descriptionState.append(")")
        }
        else if !operation.isEquals {
            descriptionState.append(symbol)
        }
        
        // save to program
        program.append(symbol)
        
        // perform the actual op now
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