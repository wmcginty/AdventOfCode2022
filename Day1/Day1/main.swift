//
//  main.swift
//  Day1
//
//  Created by Will McGinty on 12/19/22.
//

import Foundation
import Algorithms

// Part 1
func highestTotalGroup(from input: String) -> Int {
    let elements: [Int?] = input.components(separatedBy: "\n").map { $0.isEmpty ? nil : Int($0) }
    let groups: [Int] = elements.reduce(into: [0]) { partialResult, element in
        guard let element else {
            return partialResult.append(0)
        }

        partialResult[partialResult.endIndex - 1] += element
    }

    return groups.max() ?? 0
}
print("Part 1: \(highestTotalGroup(from: .input))")

// Part 2
func highestThreeGroupsTotal(from input: String) -> Int {
    let elements: [Int?] = input.components(separatedBy: "\n").map { $0.isEmpty ? nil : Int($0) }
    let groups: [Int] = elements.reduce(into: [0]) { partialResult, element in
        guard let element else { return partialResult.append(0) }

        partialResult[partialResult.endIndex - 1] += element
    }

    return groups.max(count: 3).reduce(0, +)
}
print("Part 2: \(highestThreeGroupsTotal(from: .input))")
