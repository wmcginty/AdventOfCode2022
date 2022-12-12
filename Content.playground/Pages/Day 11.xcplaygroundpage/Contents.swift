//: [Previous](@previous)

import Algorithms
import Foundation
import Parsing

let inputURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let input = try String(String(contentsOf: inputURL!, encoding: String.Encoding.utf8).dropLast(1)) // Xcode forces an empty newline at the end of the file :(

class Monkey {

    // MARK: - Subtypes
    typealias Item = Int

    enum Operation {
        enum Token {
            case old
            case number(Item)

            init(string: Substring ) {
                guard let int = Item(string) else {
                    self = .old; return
                }

                self = .number(int)
            }

            func value(usingOldValue old: Item) -> Item {
                switch self {
                case .old: return old
                case .number(let int): return int
                }
            }
        }

        case add(Token, Token)
        case subtract(Token, Token)
        case multiply(Token, Token)

        // MARK: - Initializer
        init(lToken: Token, rToken: Token, operation: Substring) {
            switch operation {
            case "+": self = .add(lToken, rToken)
            case "-": self = .subtract(lToken, rToken)
            default: self = .multiply(lToken, rToken)
            }
        }

        // MARK: - Interface
        func applied(to item: Item) -> Item {
            switch self {
            case .add(let lToken, let rToken):
                return lToken.value(usingOldValue: item) + rToken.value(usingOldValue: item)
            case .subtract(let lToken, let rToken):
                return lToken.value(usingOldValue: item) - rToken.value(usingOldValue: item)
            case .multiply(let lToken, let rToken):
                return lToken.value(usingOldValue: item) * rToken.value(usingOldValue: item)
            }
        }
    }

    struct Test {
        let divisibleBy: Int
        let trueDestinationMonkey: Int
        let falseDestinationMonkey: Int

        func destinationMonkey(for item: Item) -> Int {
            if item % Item(divisibleBy) == 0 {
                return trueDestinationMonkey
            } else {
                return falseDestinationMonkey
            }
        }
    }

    enum ReliefMethod {
        case itemsNotDamaged
        case automathic(lcm: Item)
    }

    // MARK: - Properties
    let number: Int
    var items: [Item]
    let operation: Operation
    let test: Test
    var inspectionCount: Int = 0

    init(number: Int, items: [Item], operation: Operation, test: Test) {
        self.number = number
        self.items = items
        self.operation = operation
        self.test = test
    }

    // MARK: - Interface
    func inspectItem(atIndex idx: Int) {
        items[idx] = operation.applied(to: items[idx])
        inspectionCount += 1
    }

    func applyReliefToItem(atIndex idx: Int, using method: ReliefMethod) {
        switch method {
        case .automathic(let lcm): items[idx] %= lcm
        case .itemsNotDamaged: items[idx] = Item((Float(items[idx]) / 3).rounded(.down))
        }
    }
}

class GangOfMonkeys {

    var monkeys: [Monkey]

    init(monkeys: [Monkey]) {
        self.monkeys = monkeys
    }

    func doTurn(for monkey: Monkey, reliefMethod: Monkey.ReliefMethod) {
        let currentItems = monkey.items

        while !monkey.items.isEmpty {
            monkey.inspectItem(atIndex: 0)
            monkey.applyReliefToItem(atIndex: 0, using: reliefMethod)

            let first = monkey.items.removeFirst()
            let destination = monkey.test.destinationMonkey(for: first)
            monkeys[destination].items.append(first)
        }
    }

    func doRounds(_ count: Int = 1, reliefMethod: Monkey.ReliefMethod) {
        for _ in 0..<count {
            for monkey in monkeys {
                doTurn(for: monkey, reliefMethod: reliefMethod)
            }
        }
    }
}

// Monkey Parsing (That was not fun :( )
let monkeyNumberParse = Parse {
    "Monkey "
    Int.parser()
    ":\n"
}

let monkeyItemsParse = Parse {
    Prefix(while: { $0 != ":" })
    ": "
    Many(element: { Monkey.Item.parser() }, separator: { ", " })
    Prefix(while: { $0 != "\n"})
    "\n"
}.map { _, items, _ in items }

let monkeyOperationPartParse = Parse {
    Prefix(while: { $0 != " "})
    " "
}

let monkeyOperationParse = Parse {
    Prefix(while: { $0 == " " })
    "Operation: new = "
    monkeyOperationPartParse
    monkeyOperationPartParse
    Prefix(while: { $0 != "\n" })
    "\n"
}.map { _, part1, part2, part3 in
    Monkey.Operation(lToken: .init(string: part1), rToken: .init(string: part3), operation: part2)
}

let monkeyTestResultParse = Parse {
    Prefix(while: { $0 != ":"})
    ": throw to monkey "
    Int.parser()
}.map { $1 }

let monkeyTestParse = Parse {
    Prefix(while: { $0 == " " })
    "Test: divisible by "
    Int.parser()
    monkeyTestResultParse
    monkeyTestResultParse
}.map { _, divisor, trueMonkey, falseMonkey in
    Monkey.Test(divisibleBy: divisor, trueDestinationMonkey: trueMonkey, falseDestinationMonkey: falseMonkey)
}

let monkeyParse = Parse {
    monkeyNumberParse
    monkeyItemsParse
    monkeyOperationParse
    monkeyTestParse
}.map { Monkey(number: $0, items: $1, operation: $2, test: $3) }

// MARK: - Part 1
func reliefFilledMonkeyGangMonkeyBusiness(with input: String) throws -> Int {
    let monkeys = try Many { monkeyParse } separator: { "\n\n" }.parse(input)
    let gang = GangOfMonkeys(monkeys: monkeys)
    gang.doRounds(20, reliefMethod: .itemsNotDamaged)

    let inspectionCounts = gang.monkeys.map(\.inspectionCount)
    return inspectionCounts.max(count: 2).reduce(1, *)
}

print("Part 1: \(try reliefFilledMonkeyGangMonkeyBusiness(with: input))")

// MARK: - Part 2
func monkeyGangMonkeyBusiness(with input: String) throws -> Int {
    let monkeys = try Many { monkeyParse } separator: { "\n\n" }.parse(input)
    let gang = GangOfMonkeys(monkeys: monkeys)
    let lcm = monkeys.reduce(1) { $0 * $1.test.divisibleBy }
    gang.doRounds(10_000, reliefMethod: .automathic(lcm: lcm))

    let inspectionCounts = gang.monkeys.map(\.inspectionCount)
    return inspectionCounts.max(count: 2).reduce(1, *)
}

print("Part 2: \(try monkeyGangMonkeyBusiness(with: input))")

//: [Next](@next)
