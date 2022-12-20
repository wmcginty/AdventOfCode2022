//
//  main.swift
//  Day20
//
//  Created by Will McGinty on 12/20/22.
//

import Foundation
import AdventKit
import Algorithms

class CircleNode {

    // MARK: - Properties
    let value: Int
    let shift: Int

    var next: CircleNode?
    var previous: CircleNode?

    // MARK: - Initializers
    init(value: Int, shift: Int) {
        self.value = value
        self.shift = shift
    }

    // MARK: - Preset
    static func circleOfNodes(from integers: [Int]) -> [CircleNode] {
        let circle = integers.map {
            CircleNode(value: $0, shift: $0 % (integers.count - 1))
        }

        // link the items together
        for (a, b) in circle.adjacentPairs() {
            a.next = b
            b.previous = a
        }

        // link the first and last items to make a circle
        circle.first?.previous = circle.last
        circle.last?.next = circle.first

        return circle
    }

    // MARK: - Interface
    static func swap(lhs: CircleNode, rhs: CircleNode) {
        let prev = lhs.previous
        let next = rhs.next

        next?.previous = lhs
        lhs.previous = rhs
        lhs.next = next
        rhs.previous = prev
        rhs.next = lhs
        prev?.next = rhs
    }
}

// MARK: - Helper
func mix(circle: [CircleNode]) {
    let halfCircleLength = circle.count / 2

    for node in circle {
        var absoluteShift = abs(node.shift)
        var value = node.value

        // make sure to traverse the shortest distance around the cirlce
        if absoluteShift > halfCircleLength {
            absoluteShift = circle.count - absoluteShift - 1
            value *= -1
        }

        // move it
        (0..<absoluteShift).forEach { _ in
            if value < 0 {
                CircleNode.swap(lhs: node.previous!, rhs: node)
            } else {
                CircleNode.swap(lhs: node, rhs: node.next!)
            }
        }
    }
}

func value(atCoordinate coordinate: Int, for circle: [CircleNode]) -> Int {
    var currentNode = circle.first(where: { $0.value == 0 })
    (0..<coordinate).forEach { _ in
        currentNode = currentNode?.next
    }

    return currentNode?.value ?? 0
}

// MARK: - Part 1
func sumOfValuesAtGivenCoordinates(from input: String) -> Int {
    let integers = input.components(separatedBy: .newlines).compactMap(Int.init)
    let circle = CircleNode.circleOfNodes(from: integers)
    mix(circle: circle)

    return [value(atCoordinate: 1000, for: circle), value(atCoordinate: 2000, for: circle), value(atCoordinate: 3000, for: circle)].reduce(0, +)
}

measure(part: .one) {
    print("Solution: \(sumOfValuesAtGivenCoordinates(from: .input))")
}

// MARK: - Part 2
func sumOfActualValuesAtGivenCoordinates(from input: String) -> Int {
    let integers = input.components(separatedBy: .newlines).compactMap(Int.init).map { $0 * 811589153 }
    let circle = CircleNode.circleOfNodes(from: integers)

    (0..<10).forEach { _ in
        mix(circle: circle)
    }

    return [value(atCoordinate: 1000, for: circle), value(atCoordinate: 2000, for: circle), value(atCoordinate: 3000, for: circle)].reduce(0, +)
}

measure(part: .two) {
    print("Solution: \(sumOfActualValuesAtGivenCoordinates(from: .input))")
}
