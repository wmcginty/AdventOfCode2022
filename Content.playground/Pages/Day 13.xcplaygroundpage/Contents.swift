//: [Previous](@previous)

import Algorithms
import Foundation
import Parsing

let inputURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let input = try String(String(contentsOf: inputURL!, encoding: String.Encoding.utf8).dropLast(1)) // Xcode forces an empty newline at the end of the file :(

// MARK: - Array + Comparable
extension Array: Comparable where Element: Comparable {

    public static func < (lhs: [Element], rhs: [Element]) -> Bool {
        for (leftElement, rightElement) in zip(lhs, rhs) {
            if leftElement < rightElement {
                return true
            } else if leftElement > rightElement {
                return false
            }
        }

        return lhs.count < rhs.count
    }
}

struct Packet: Comparable {

    // MARK: - Packet.Element
    indirect enum Element: Comparable {
        case integer(Int)
        case array([Element])

        enum Comparison {
            case inOrder
            case outOfOrder
            case matching
        }

        // MARK: - In Order
        func comparison(with other: Element) -> Comparison {
            switch (self, other) {
            case let (.array(lArray), .array(rArray)):
                for (l, r) in zip(lArray, rArray) {
                    switch l.comparison(with: r) {
                    case .inOrder: return .inOrder
                    case .outOfOrder: return .outOfOrder
                    case .matching: continue
                    }
                }

                if lArray.count == rArray.count {
                    return .matching
                }

                return lArray.count < rArray.count ? .inOrder : .outOfOrder

            case let (.integer(lInt), .integer(rInt)):
                if lInt == rInt {
                    return .matching
                }

                return lInt < rInt ? .inOrder : .outOfOrder

            case let (.integer(lInt), .array(rArray)): return Packet.Element.array([.integer(lInt)]).comparison(with: .array(rArray))
            case let (.array(lArray), .integer(rInt)): return Packet.Element.array(lArray).comparison(with: .array([.integer(rInt)]))
            }
        }

        // MARK: - Comparable
        static func < (lhs: Element, rhs: Element) -> Bool {
            switch (lhs, rhs) {
            case let (.array(lArray), .array(rArray)): return lArray < rArray
            case let (.integer(lInt), .integer(rInt)): return lInt < rInt
            case let (.integer(lInt), .array(rArray)): return Packet.Element.array([.integer(lInt)]) < .array(rArray)
            case let (.array(lArray), .integer(rInt)): return Packet.Element.array(lArray) < .array([.integer(rInt)])
            }
        }
    }

    // MARK: - Properties
    let element: [Element]

    // MARK: - Preset
    static let divider1 = Packet(element: [.array([.integer(2)])])
    static let divider2 = Packet(element: [.array([.integer(6)])])

    // MARK: - In Order
    func isInOrder(with other: Packet) -> Bool {
        for (l, r) in zip(element, other.element) {
            switch l.comparison(with: r) {
            case .outOfOrder: return false
            case .matching: continue
            case .inOrder: return true
            }
        }

        return element.count < other.element.count
    }

    // MARK: - Comparable
    static func < (lhs: Packet, rhs: Packet) -> Bool {
        return lhs.element < rhs.element
    }
}

struct PacketPair {
    let left: Packet
    let right: Packet

    var isInOrder: Bool {
        return left.isInOrder(with: right)
    }
}

// MARK: - Parsers
enum Parser {

    static var input = Many { packetPair } separator: { Whitespace(2, .vertical) }

    static var packetPair = ParsePrint {
        listParse
        Whitespace(1, .vertical)
        listParse
    }.map { (left, right) in
        PacketPair(left: .init(element: left), right: .init(element: right))
    }

    static var listParse: AnyParserPrinter<Substring, [Packet.Element]> {
        ParsePrint {
            "["
            Many { valueParse } separator: { "," }
            "]"
        }
        .eraseToAnyParserPrinter()
    }

    static var valueParse: AnyParserPrinter<Substring, Packet.Element> {
        OneOf {
            Int.parser().map(.case(Packet.Element.integer))
            Lazy { listParse.map(.case(Packet.Element.array)) }
        }
        .eraseToAnyParserPrinter()
    }
}

// MARK: - Part 1
func sumOfIndicesOfPairsInCorrectOrder(from input: String) throws -> Int {
    let packetPairs = try Parser.input.parse(input)
    return packetPairs.indexed().filter { $0.element.isInOrder }.map { $0.index + 1 }.reduce(0, +)
}

print("Part 1: \(try sumOfIndicesOfPairsInCorrectOrder(from: input))")

// MARK: - Part 2
func productOfDividerPacketIndices(from input: String) throws -> Int {
    let packetPairs = try Parser.input.parse(input)
    let packets = (packetPairs.flatMap { [$0.left, $0.right] }  + [.divider1, .divider2]).sorted()

    guard let firstIndex = packets.firstIndex(of: .divider1), let secondIndex = packets.firstIndex(of: .divider2) else { return 0 }
    return (firstIndex + 1) * (secondIndex + 1)
}

print("Part 2: \(try productOfDividerPacketIndices(from: input))")

//: [Next](@next)
