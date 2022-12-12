//: [Previous](@previous)

import Foundation
import Algorithms

let inputURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let input = try String(String(contentsOf: inputURL!, encoding: String.Encoding.utf8).dropLast(1)) // Xcode forces an empty newline at the end of the file :(

// MARK: - Part 1
func indexOfFirstUniqueWindow(ofLength length: Int, from input: String) -> Int? {
    return input.windows(ofCount: length)
        .enumerated()
        .first { Set($0.element).count ==Day 
}

print("Part 1: \(indexOfFirstUniqueWindow(ofLength: 4, from: input) ?? 0)")
print("Part 2: \(indexOfFirstUniqueWindow(ofLength: 14, from: input) ?? 0)")


//: [Next](@next)
