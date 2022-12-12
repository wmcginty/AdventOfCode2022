//: [Previous](@previous)

import Foundation
import Parsing

let inputURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let input = try String(String(contentsOf: inputURL!, encoding: String.Encoding.utf8).dropLast(1)) // Xcode forces an empty newline at the end of the file :(

enum Direction: String {
    case left = "L"
    case right = "R"
    case up = "U"
    case down = "D"
}

struct Move {
    let direction: Direction
    let amount: Int

    func adjustedCoordinate(from coord: Coordinate) -> Coordinate {
        switch direction {
        case .up: return .init(x: coord.x, y: coord.y + amount)
        case .down: return .init(x: coord.x, y: coord.y - amount)
        case .left: return .init(x: coord.x - amount, y: coord.y)
        case .right: return .init(x: coord.x + amount, y: coord.y)
        }
    }

    func normalized() -> [Move] {
        return Array(repeating: Move(direction: direction, amount: 1), count: amount)
    }
}

struct Coordinate: CustomStringConvertible, Hashable {
    let x, y: Int

    var description: String {
        return "(\(x), \(y))"
    }

    func isTouching(other point: Coordinate) -> Bool {
        return abs(x - point.x) <= 1 && abs(y - point.y) <= 1
    }

    mutating func update(for point: Coordinate) {
        if isTouching(other: point) {
            return
        }

        self = .init(x: x + (point.x - x).signum(), y: y + (point.y - y).signum())
    }
}

class Node<T> {
    var value: T
    var next: Node<T>?

    init(value: T) {
        self.value = value
    }
}

class LinkedList {

    var head: Node<Coordinate>
    private var tail: Node<Coordinate>
    private(set) var tailVisitedPositions: Set<Coordinate>

    init(value: Coordinate) {
        self.head = Node(value: value)
        self.tail = head
        self.tailVisitedPositions = [tail.value]
    }

    convenience init(nodes: Int, ofValue value: Coordinate) {
        self.init(value: value)

        for _ in 0..<nodes - 1 {
            self.append(value)
        }
    }

    func append(_ value: Coordinate) {
        let node = Node(value: value)

        tail.next = node
        tail = node
    }

    func process(moves: [Move]) {
        moves.flatMap { $0.normalized() }.forEach { process(move: $0) }
    }

    func process(move: Move) {
        head.value = move.adjustedCoordinate(from: head.value)

        var current = head
        while let next = current.next {
            next.value.update(for: current.value)
            current = next
        }

        tailVisitedPositions.insert(tail.value)
    }
}

let moveParse = Parse {
    Prefix { $0 != " " }
    " "
    Int.parser()
}.map { Move(direction: Direction(rawValue: String($0))!, amount: $1) }

let moves = try Many { moveParse } separator: { "\n" }.parse(input)

let listTwo = LinkedList(nodes: 2, ofValue: .init(x: 0, y: 0))

let s1 = Date.now
listTwo.process(moves: moves)
print("Part 1: \(listTwo.tailVisitedPositions.count)")
print("Part 1 Elapsed: \(Date.now.timeIntervalSince(s1))")

let listTen = LinkedList(nodes: 10, ofValue: .init(x: 0, y: 0))

let s2 = Date.now
listTen.process(moves: moves)
print("Part 2: \(listTen.tailVisitedPositions.count)")
print("Part 2 Elapsed: \(Date.now.timeIntervalSince(s2))")

//: [Next](@next)
