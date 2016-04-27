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
    
    func setOperand(operand: Double) { accumulator = operand }
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    private var operations : Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "±" : Operation.UnaryOperation( { -$0 } ),
        "×" : Operation.BinaryOperation( { $0 * $1 } ),
        "−" : Operation.BinaryOperation( { $0 - $1 } ),
        "+" : Operation.BinaryOperation( { $0 + $1 } ),
        "÷" : Operation.BinaryOperation( { $0 / $1 } ),
        "%" : Operation.BinaryOperation( { $0 % $1 } ),
        "=" : Operation.Equals
    ]
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value): accumulator = value
            case .UnaryOperation(let function): accumulator = function(accumulator)
            case .BinaryOperation(let function):
                performBinaryOperation()
                pendingBinaryOperationInfo = PendingBinaryOperationInfo(firstOperand: accumulator, binaryFunction: function)
                pendingBinaryOperation = true
            case .Equals: performBinaryOperation()
            }
            
        }
    }
    
    private func performBinaryOperation() {
        if pendingBinaryOperation {
            accumulator = pendingBinaryOperationInfo!.binaryFunction(pendingBinaryOperationInfo!.firstOperand, accumulator)
            pendingBinaryOperation = false
        }
    }
    
    private var pendingBinaryOperation = false
    private var pendingBinaryOperationInfo : PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var firstOperand : Double
        var binaryFunction : (Double, Double) -> Double
    }
    
    var result : Double {
        get {
            return accumulator
        }
    }
}