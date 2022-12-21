//
//  main.swift
//  Day21
//
//  Created by Will McGinty on 12/21/22.
//

import Foundation
import AdventKit
import Algorithms
import Parsing

enum Operation {
    case add(Monkey.Name, Monkey.Name)
    case subtract(Monkey.Name, Monkey.Name)
    case multiply(Monkey.Name, Monkey.Name)
    case divide(Monkey.Name, Monkey.Name)

    // MARK: - Initializer
    init(lToken: Monkey.Name, rToken: Monkey.Name, operation: Substring) {
        switch operation {
        case "+": self = .add(lToken, rToken)
        case "-": self = .subtract(lToken, rToken)
        case "*": self = .multiply(lToken, rToken)
        default: self = .divide(lToken, rToken)
        }
    }

    // MARK: - Interface
    var lMonkey: Monkey.Name {
        switch self {
        case .add(let lhs, _), .subtract(let lhs, _), .multiply(let lhs, _), .divide(let lhs, _): return lhs
        }
    }

    var rMonkey: Monkey.Name {
        switch self {
        case .add(_, let rhs), .subtract(_, let rhs), .multiply(_, let rhs), .divide(_, let rhs): return rhs
        }
    }
}

struct Monkey {
    typealias Name = String

    let name: String
    let number: Number

    enum Number {
        case value(Int)
        case operation(Operation)
    }
}

struct UnsureMonkey {
    typealias Name = String

    let name: String
    let number: Number

    enum Number {
        case unknown
        case value(Int)
        case operation(Operation)

        init(_ number: Monkey.Number) {
            switch number {
            case .value(let int): self = .value(int)
            case .operation(let op): self = .operation(op)
            }
        }
    }

    var lMonkey: Monkey.Name? {
        guard case let .operation(op) = number else { return nil }
        return op.lMonkey
    }

    var rMonkey: Monkey.Name? {
        guard case let .operation(op) = number else { return nil }
        return op.rMonkey
    }
}

class Solver {

    // MARK: - Properties
    let monkeyDict: [Monkey.Name: Monkey]
    private var valueCache: [Monkey.Name: Int] = [:]

    // MARK: - Initializer
    init(monkeyDict: [Monkey.Name : Monkey]) {
        self.monkeyDict = monkeyDict
    }

    // MARK: - Interface
    func numberForMonkey(with name: Monkey.Name) -> Int {
        guard let monkey = monkeyDict[name] else { return 0 }
        if let value = valueCache[name] {
            return value
        }

        var value: Int
        switch monkey.number {
        case .value(let int): return int
        case .operation(let operation):
            switch operation {
            case let .add(lMonkey, rMonkey): value = numberForMonkey(with: lMonkey) + numberForMonkey(with: rMonkey)
            case let .subtract(lMonkey, rMonkey): value = numberForMonkey(with: lMonkey) - numberForMonkey(with: rMonkey)
            case let .multiply(lMonkey, rMonkey): value = numberForMonkey(with: lMonkey) * numberForMonkey(with: rMonkey)
            case let .divide(lMonkey, rMonkey): value = numberForMonkey(with: lMonkey) / numberForMonkey(with: rMonkey)
            }
        }

        valueCache[name] = value
        return value
    }
}

class EquationSolver {

    // MARK: - Properties
    let monkeyDict: [UnsureMonkey.Name: UnsureMonkey]
    private lazy var solver = Solver(monkeyDict: monkeyDict.compactMapValues(\.sureMonkey))
    private var equationCache: [UnsureMonkey.Name: String] = [:]

    // MARK: - Initializer
    init(monkeyDict: [UnsureMonkey.Name : UnsureMonkey]) {
        self.monkeyDict = monkeyDict
    }

    // MARK: - Interface
    func equationForMonkey(with name: Monkey.Name) -> String {
        guard let monkey = monkeyDict[name] else { return "n/a" }
        if let value = equationCache[name] {
            return value
        }

        var value: String
        switch monkey.number {
        case .unknown: return "x"
        case .value(let int): return int.formatted()
        case .operation(let operation):
            switch operation {
            case let .add(lMonkey, rMonkey): value = "(\(equationForMonkey(with: lMonkey)) + \(equationForMonkey(with: rMonkey)))"
            case let .subtract(lMonkey, rMonkey): value = "(\(equationForMonkey(with: lMonkey)) - \(equationForMonkey(with: rMonkey)))"
            case let .multiply(lMonkey, rMonkey): value = "(\(equationForMonkey(with: lMonkey)) * \(equationForMonkey(with: rMonkey)))"
            case let .divide(lMonkey, rMonkey): value = "(\(equationForMonkey(with: lMonkey)) / \(equationForMonkey(with: rMonkey)))"
            }
        }

        equationCache[name] = value
        return value
    }
}

let operationParser = Parse {
    Prefix(while: { $0 != " " })
    " "
    Prefix(while: { $0 != " " })
    " "
    Prefix(while: { $0 != "\n" })
}.map { Monkey.Number.operation(.init(lToken: String($0), rToken: String($2), operation: $1)) }

let monkeyParser = Parse {
    Prefix(while: { $0 != ":" })
    ": "
    OneOf {
        Int.parser().map { Monkey.Number.value($0) }
        operationParser
    }
}.map { Monkey(name: String($0), number: $1) }

let inputParser = Many { monkeyParser } separator: { "\n" }

// MARK: - Part 1
func numberThatRootMonkeyYells(from input: String) throws -> Int {
    let monkeys = try inputParser.parse(input)
    let solver = Solver(monkeyDict: Dictionary(uniqueKeysWithValues: monkeys.map { ($0.name, $0) }))
    return solver.numberForMonkey(with: "root")
}

try measure(part: .one) {
    print("Solution: \(try numberThatRootMonkeyYells(from: .input))")
}

// MARK: - Part 2
func equationForWhatINeedToYell(from input: String) throws -> String {
    let monkeys = try inputParser.parse(input).map { UnsureMonkey(name: $0.name, number: .init($0.number)) }

    var monkeyDict = Dictionary(uniqueKeysWithValues: monkeys.map { ($0.name, $0) })
    monkeyDict["humn"] = .init(name: "humn", number: .unknown)

    let solver = EquationSolver(monkeyDict: monkeyDict)
    let root = monkeyDict["root"]!
    return solver.equationForMonkey(with: root.lMonkey!) + " = " + solver.equationForMonkey(with: root.rMonkey!)
}

try measure(part: .two) {
    print("Solution: \(try equationForWhatINeedToYell(from: .input))")
}
