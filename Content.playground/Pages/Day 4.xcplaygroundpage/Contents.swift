//: [Previous](@previous)

import Foundation

let inputURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let input = try String(String(contentsOf: inputURL!, encoding: String.Encoding.utf8).dropLast(1)) // Xcode forces an empty newline at the end of the file :(

extension ClosedRange where Bound == Int {

    init?(string: String) {
        let components = string.components(separatedBy: "-")
        guard let lower = Int(components[0]), let upper = Int(components[1]) else { return nil }

        self = lower...upper
    }
}

struct RangePair {

    let first: ClosedRange<Int>
    let second: ClosedRange<Int>

    init(_ ranges: [ClosedRange<Int>]) {
        self.first = ranges[0]
        self.second = ranges[1]
    }

    var firstIsSubsetOfSecond: Bool {
        return first.clamped(to: second) == first || second.clamped(to: first) == second
    }

    var overlap: Bool {
        return first.overlaps(second) || second.overlaps(first)
    }
}

// Part 1
func numberOfFullyContainedPairs(from input: String) -> Int {
    return input.components(separatedBy: .newlines)
        .map { $0.components(separatedBy: ",") }
        .map { $0.compactMap { ClosedRange<Int>(string: $0) } }
        .map { RangePair($0) }
        .filter { $0.firstIsSubsetOfSecond }.count
}
print("Part 1: \(numberOfFullyContainedPairs(from: input))")

// Part 2
func numberOfOverlappingPairs(from input: String) -> Int {
    return input.components(separatedBy: .newlines)
        .map { $0.components(separatedBy: ",") }
        .map { $0.compactMap { ClosedRange<Int>(string: $0) } }
        .map { RangePair($0) }
        .filter { $0.overlap }.count
}
print("Part 2: \(numberOfOverlappingPairs(from: input))")

//: [Next](@next)
