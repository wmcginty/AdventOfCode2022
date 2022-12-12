//: [Previous](@previous)

import Foundation
import Algorithms

let inputURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let input = try String(String(contentsOf: inputURL!, encoding: String.Encoding.utf8).dropLast(1)) // Xcode forces an empty newline at the end of the file :(

extension Character {

    var priority: UInt8? {
        return asciiValue.map { $0 - (isUppercase ? 38 : 96) }
    }
}

extension Substring {
    var priority: UInt8? {
        return Character(String(self)).priority
    }
}

struct SplitString {
    let first: Substring
    let second: Substring

    var characters: Set<Character> {
        return Set(first).union(Set(second))
    }

    var intersection: Character? {
        Set(first).intersection(Set(second)).first
    }

    var priority: Int? {
        return intersection.flatMap { $0.priority.map(Int.init) }
    }
}

extension String {

    func splitInHalf() -> SplitString {
        let halfCount = Int(Double(count) * 0.5)
        let halfIndex = index(startIndex, offsetBy: halfCount)
        return .init(first: self[..<halfIndex], second: self[halfIndex...])
    }
}

func sumOfPriorities(from input: String) -> Int {
    return input.components(separatedBy: .newlines)
        .map { $0.splitInHalf() }
        .compactMap(\.priority)
        .reduce(0, +)
}

print("Part 1: \(sumOfPriorities(from: input))")

func sumOfGroupPriorities(from input: String) -> Int {
    return input.components(separatedBy: .newlines)
        .map { return $0.splitInHalf() }
        .chunks(ofCount: 3)
        .compactMap { chunk in
            return chunk.reduce(Set<Character>()) { partialResult, element in
                guard !partialResult.isEmpty else { return element.characters }
                return partialResult.intersection(element.characters)
            }.first
        }
        .compactMap { $0.priority.map(Int.init) }
        .reduce(0, +)
}

print("Part 2: \(sumOfGroupPriorities(from: input))")

//: [Next](@next)
