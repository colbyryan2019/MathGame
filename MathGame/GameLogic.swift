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
    let difficulty: Difficulty

    
    init(difficulty: Difficulty = .medium) {
        self.difficulty = difficulty
        targetNumber = -1

        repeat {
            numbers = (1...difficulty.numberOfNumbers).map { _ in Int.random(in: difficulty.range) }

            repeat {
                operations = (1...(difficulty.numberOfNumbers - 1)).map { _ in
                    ["+", "-", "*"].randomElement()!
                }
            } while allSameOperators() || tooManyMultiplications(for: difficulty)

            targetNumber = MathGame.calculateTargetWithOrder(numbers: numbers, operations: operations)
            numbers.shuffle()
        } while(targetNumber < 0)

        print("gamelogic init")
        print("target number:", targetNumber)
        print("numbers=", numbers)
        print("operations: ", operations)
    }


    private func allSameOperators() -> Bool {
        guard let first = operations.first else { return false }
        return operations.allSatisfy { $0 == first }
    }

    private func tooManyMultiplications(for difficulty: Difficulty) -> Bool {
        let multiplicationCount = operations.filter { $0 == "*" }.count
        if difficulty == .hard {
            return multiplicationCount > 2
        }
        return false
    }
    
    // Function to calculate target with left-to-right operations (basic mode)
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
    
    // Static method to calculate result with order of operations (PEMDAS)
    static func calculateTargetWithOrder(numbers: [Int], operations: [String]) -> Int {
        var expression: [Any] = []
        
        // Interleave numbers and operations into an array
        for (i, num) in numbers.enumerated() {
            expression.append(num)
            if i < operations.count {
                expression.append(operations[i])
            }
        }
        
        // **First pass: Handle Multiplication**
        var newExpression: [Any] = []
        var index = 0
        
        while index < expression.count {
            if let op = expression[index] as? String, op == "*" {
                let left = newExpression.removeLast() as! Int
                let right = expression[index + 1] as! Int
                newExpression.append(left * right)
                index += 2
            } else {
                newExpression.append(expression[index])
                index += 1
            }
        }
        
        // **Second pass: Handle Addition and Subtraction**
        var result = newExpression[0] as! Int
        index = 1
        
        while index < newExpression.count {
            let op = newExpression[index] as! String
            let right = newExpression[index + 1] as! Int
            
            if op == "+" {
                result += right
            } else if op == "-" {
                result -= right
            }
            
            index += 2
        }
        
        return result
    }
}
