//
//  main.swift
//  Day6
//
//  Created by Will McGinty on 12/19/22.
//

import Foundation
import Algorithms

func indexOfFirstUniqueWindow(ofLength length: Int, from input: String) -> Int? {
    return input.windows(ofCount: length)
        .enumerated()
        .first { Set($0.element).count == $0.element.count }?.offset
}

print("Part 1: \(indexOfFirstUniqueWindow(ofLength: 4, from: .input) ?? 0)")
print("Part 2: \(indexOfFirstUniqueWindow(ofLength: 14, from: .input) ?? 0)")


