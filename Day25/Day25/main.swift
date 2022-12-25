//
//  main.swift
//  Day25
//
//  Created by Will McGinty on 12/24/22.
//

import Foundation
import AdventKit
import Algorithms

struct SnafuNumber: CustomStringConvertible {

    // MARK: - SnafuNumber.Digit
    enum Digit: String {
        case zero = "=" // worth -2
        case one = "-" // worth -1
        case two = "0"
        case three = "1"
        case four = "2"

        var worth: Int {
            switch self {
            case .zero: return -2
            case .one: return -1
            case .two: return 0
            case .three: return 1
            case .four: return 2
            }
        }
    }

    // MARK: - Properties
    let digits: [Digit]

    // MARK: - Initializers
    init(string: String) {
        self.digits = string.map { Digit(rawValue: String($0))! }
    }

    init(decimalNumber: Int) {
        var num = decimalNumber
        var d: [Digit] = []

        while num > 0 {
            switch num % 5 {
            case 0:
                d.insert(.two, at: 0)
            case 1:
                d.insert(.three, at: 0)
            case 2:
                d.insert(.four, at: 0)
            case 3:
                d.insert(.zero, at: 0)
                num += 5
            case 4:
                d.insert(.one, at: 0)
                num += 5
            default: break
            }

            num /= 5
        }

        self.digits = d
    }

    // MARK: - Interface
    var decimalNumber: Int {
        var total = 0
        var place = 1
        for digit in digits.reversed().indexed() {
            total += digit.element.worth * place
            place *= 5
        }

        return total
    }

    // MARK: - CustomStringConvertible
    var description: String {
        return digits.map(\.rawValue).joined()
    }
}

// MARK: - Part 1
func part1(from input: String) throws -> String {
    let sumOfSnafuNumbers = input
        .components(separatedBy: .newlines)
        .map(SnafuNumber.init)
        .map(\.decimalNumber)
        .reduce(0, +)

    let snafuNumber = SnafuNumber(decimalNumber: sumOfSnafuNumbers)
    return snafuNumber.description
}

try measure(part: .one) {
    print("Solution: \(try part1(from: .input))")
}
