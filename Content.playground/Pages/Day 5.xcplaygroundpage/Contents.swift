
//: [Previous](@previous)

import Foundation
import Parsing

let inputURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let input = try String(String(contentsOf: inputURL!, encoding: String.Encoding.utf8).dropLast(1)) // Xcode forces an empty newline at the end of the file :(

// MARK: - Crate
enum Crate {
    case full(String)
    case empty
}

// MARK: - MoveStep
struct MoveStep {
    let amount: Int
    let sourceColumn: Int
    let destinationColumn: Int
}

// MARK: - Stack
struct Stack<T> {
    private var contents: [T]

    init() {
        self.contents = []
    }

    var isEmpty: Bool { return contents.isEmpty }
    var top: T? { return contents.first }

    mutating func push(_ element: T) {
        contents.insert(element, at: 0)
    }

    mutating func pop() -> T {
        return contents.removeFirst()
    }
}

// MARK: - Towers
struct Towers<T> {
    private(set) var stacks: [Stack<T>]

    init(lines: String) throws where T == String {
        var splitByNewlines = lines.components(separatedBy: .newlines)
        let stackDefinitionLine = splitByNewlines.removeLast()

        let stacksCount = Int((Float(stackDefinitionLine.count) / 4).rounded(.up))
        self.stacks = Array(repeating: .init(), count: stacksCount)

        for line in splitByNewlines.reversed() {
            let crates = try crateElements.parse(line)
            for (index, element) in crates.enumerated() {
                switch element {
                case .empty: continue
                case .full(let str): stacks[index].push(str)
                }
            }
        }
    }

    var topOfEach: [T] { return stacks.compactMap(\.top) }

    mutating func apply(steps: [MoveStep], moveAllAtOnce: Bool = false) {
        steps.forEach { apply(step: $0, moveAllAtOnce: moveAllAtOnce) }
    }

    mutating func apply(step: MoveStep, moveAllAtOnce: Bool = false) {
        guard moveAllAtOnce else {
            for _ in 0..<step.amount {
                let element = stacks[step.sourceColumn - 1].pop()
                stacks[step.destinationColumn - 1].push(element)
            }

            return
        }

        let moved = (0..<step.amount).map { _ in stacks[step.sourceColumn - 1].pop() }.reversed()
        moved.forEach { stacks[step.destinationColumn - 1].push($0) }
    }
}

// MARK: - Parsing
let crate = Parse {
    "["
    Prefix(while:  { $0 != "]" })
    "]"
}.map { Crate.full(String($0)) }

let emptyCrate = Parse {
    "   "
}.map { _ in Crate.empty }

let crateElement = Parse {
    OneOf {
        crate
        emptyCrate
    }
}

let crateElements =  Many { crateElement } separator: { " " }

let step = Parse {
    "move "
    Int.parser()
    " from "
    Int.parser()
    " to "
    Int.parser()
}
.map { MoveStep(amount: $0, sourceColumn: $1, destinationColumn: $2) }

let steps = Many { step } separator: { "\n" }

// MARK: - Part 1
func topOfEachStackAfterRearrangement(from input: String) throws -> String {
    let splitByDoubleNewLine = input.components(separatedBy: "\n\n")
    let (stackLines, stepLines) =  (splitByDoubleNewLine[0], splitByDoubleNewLine[1])

    var towers = try Towers(lines: stackLines)
    let moveSteps = try steps.parse(stepLines)
    towers.apply(steps: moveSteps)

    return towers.topOfEach.joined()
}

print("Part 1: \(try topOfEachStackAfterRearrangement(from: input))")

// MARK: - Part 2
func topOfEachStackAfterModifiedRearrangement(from input: String) throws -> String {
    let splitByDoubleNewLine = input.components(separatedBy: "\n\n")
    let (stackLines, stepLines) =  (splitByDoubleNewLine[0], splitByDoubleNewLine[1])

    var towers = try Towers(lines: stackLines)
    let moveSteps = try steps.parse(stepLines)
    towers.apply(steps: moveSteps, moveAllAtOnce: true)

    return towers.topOfEach.joined()
}

print("Part 2: \(try topOfEachStackAfterModifiedRearrangement(from: input))")

//: [Next](@next)
