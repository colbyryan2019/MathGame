//
//  GameLogic.swift
//  MathGame
//
//  Created by Colby Ryan on 11/12/24.
//

import Foundation

struct MathGame {
    var targetNumber: Int
    var operations: [String]
    var numbers: [Int]
    
    init(numberOfNumbers: Int = 3, range: ClosedRange<Int> = 2...12) {
        // Generate numbers and operations
        targetNumber = -1
        repeat{
            numbers = (1...numberOfNumbers).map { _ in Int.random(in: range) }
            operations = ["+", "-", "*"].shuffled().prefix(numberOfNumbers - 1).map { $0 }
            
            // Generate a target number based on the operations and numbers
            
            targetNumber = MathGame.calculateTargetWithOrder(numbers: numbers, operations: operations)
            numbers.shuffle()
        }while(targetNumber < 0)
        print("gamelogic init")
    }
    
    //Old function calculates left to right, ignoring order of operations. Didn't delete, could be useful in some gamemodes?
    static func calculateTarget(numbers: [Int], operations: [String]) -> Int {
        var result = numbers[0]
        for (index, operation) in operations.enumerated() {
            let nextNumber = numbers[index + 1]
            switch operation {
            case "+":
                result += nextNumber
            case "-":
                result -= nextNumber
            case "*":
                result *= nextNumber
            default:
                break
            }
        }
        return result
    }
    
    // Static method to calculate result with order of operations
    static func calculateTargetWithOrder(numbers: [Int], operations: [String]) -> Int {
        var expression = zip(numbers, operations + [""]).flatMap { [$0.0, $0.1] }
        
        // Handle *, / first
        var index = 1
        while index < expression.count - 1 {
            if let op = expression[index] as? String, op == "*" || op == "/" {
                let left = expression[index - 1] as! Int
                let right = expression[index + 1] as! Int
                let result = op == "*" ? left * right : (right != 0 ? left / right : left) // Prevent divide by 0
                expression.replaceSubrange(index - 1...index + 1, with: [result])
                index -= 1
            }
            index += 2
        }
        
        // Handle +, - next
        var result = expression[0] as! Int
        index = 1
        while index < expression.count - 1 {
            if let op = expression[index] as? String {
                let right = expression[index + 1] as! Int
                result = op == "+" ? result + right : result - right
            }
            index += 2
        }
        
        return result
    }
    
}
