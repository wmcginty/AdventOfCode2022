//
//  main.swift
//  Day23
//
//  Created by Will McGinty on 12/22/22.
//

import Foundation
import AdventKit

struct Grid: CustomStringConvertible {

    // MARK: - Grid.ProposedMove
    enum ProposedMove {
        case none
        case north
        case south
        case east
        case west

        var neighborDirections: [Coordinate.Direction] {
            switch self {
            case .none: return Coordinate.Direction.allCases
            case .north: return [.north, .northEast, .northWest]
            case .south: return [.south, .southEast, .southWest]
            case .east: return [.east, .southEast, .northEast]
            case .west: return [.west, .southWest, .northWest]
            }
        }
    }

    // MARK: - Grid.Content
    enum Content: String, Equatable {
        case elf = "#"
        case ground = "."

        init?(character: Character) {
            self.init(rawValue: String(character))
        }
    }

    // MARK: - Properties
    private var elfCoordinates: Set<Coordinate>
    private var rotatingMoveProposalOrder: [ProposedMove] = [.north, .south, .west, .east]
    private(set) var rounds: Int = 0

    // MARK: - Initializer
    init(elements: [[Content]]) {
        self.elfCoordinates = []

        for row in elements.indices {
            for col in elements[row].indices {
                if elements[row][col] == .elf {
                    self.elfCoordinates.insert(.init(x: col, y: row))
                }
            }
        }
    }

    // MARK: - Interface
    var minX: Int { return elfCoordinates.map(\.x).min()! }
    var maxX: Int { return elfCoordinates.map(\.x).max()! }
    var minY: Int { return elfCoordinates.map(\.y).min()! }
    var maxY: Int { return elfCoordinates.map(\.y).max()! }

    var smallestRectangleContainingAllElves: [Coordinate] {
        var result: [Coordinate] = []
        for row in minY...maxY {
            for col in minX...maxX {
                result.append(.init(x: col, y: row))
            }
        }

        return result
    }

    func element(at coordinate: Coordinate) -> Content {
        return elfCoordinates.contains(coordinate) ? .elf : .ground
    }

    mutating func set(_ element: Content, at coordinate: Coordinate) {
        switch element {
        case .ground: elfCoordinates.remove(coordinate)
        case .elf: elfCoordinates.insert(coordinate)
        }
    }

    mutating func performRounds(_ count: Int, visualize: Bool = false) {
        if visualize {
            print("Start:")
            print(self.description)
        }

        for index in 1...count {
            rounds += 1

            let noneMoved = performRound()
            if visualize && index % 5 == 0 {
                print("Turn \(index):")
                print(self.description)
            }

            if noneMoved {
                break
            }
        }
    }

    mutating func performRound() -> Bool {
        var proposedMoves: [Coordinate: Coordinate] = [:]

        for coord in elfCoordinates {
            let proposedMove = proposedMoveForElf(at: coord)

            switch proposedMove {
            case .none: proposedMoves[coord] = coord
            case .east: proposedMoves[coord] = coord.moved(in: .east, amount: 1)
            case .west: proposedMoves[coord] = coord.moved(in: .west, amount: 1)
            case .south: proposedMoves[coord] = coord.moved(in: .south, amount: 1)
            case .north: proposedMoves[coord] = coord.moved(in: .north, amount: 1)
            }
        }

        if proposedMoves.allSatisfy({ $0.key == $0.value }) {
            return true
        }

        let destinationCounts = proposedMoves.reduce(into: [Coordinate: Int]()) { $0[$1.value, default: 0] += 1 }
        let allowedMoves = proposedMoves.filter { destinationCounts[$0.value, default: 0] <= 1 }

        for (key, value) in allowedMoves {
            set(.ground, at: key)
            set(.elf, at: value)
        }

        let first = rotatingMoveProposalOrder.removeFirst()
        rotatingMoveProposalOrder.append(first)
        return false
    }

    func proposedMoveForElf(at coordinate: Coordinate) -> ProposedMove {
        if coordinate.neighbors().map(element(at:)).allSatisfy({ $0 == .ground }) {
            return .none
        }

        for index in rotatingMoveProposalOrder.indices {
            let proposedMove = rotatingMoveProposalOrder[index]
            if areNeighborsAllEmpty(at: coordinate.neighbors(in: proposedMove.neighborDirections)) {
                return proposedMove
            }
        }

        return .none
    }

    func areNeighborsAllEmpty(at coordinates: [Coordinate]) -> Bool {
        return coordinates.map(element(at:)).allSatisfy { $0 == .ground }
    }

    // MARK: - CustomStringConvertible
    var description: String {
        var result: String = ""
        for row in (minY - 1)...(maxY + 1) {
            for col in (minX - 1)...(maxX + 1) {
                result += element(at: .init(x: col, y: row)).rawValue
            }

            result += "\n"
        }

        return result
    }
}

// MARK: - Helper
func prepareGrid(from input: String) -> Grid {
    let contents = input.components(separatedBy: .newlines).map { $0.compactMap { Grid.Content(character: $0) } }
    return Grid(elements: contents)
}

// MARK: - Part 1
func groundTilesInSmallestRectangleContainingAllElvesAfter(rounds: Int, from input: String) throws -> Int {
    var grid = prepareGrid(from: input)
    grid.performRounds(10, visualize: false)
    let smallestRectangle = grid.smallestRectangleContainingAllElves

    return smallestRectangle.filter { grid.element(at: $0) == .ground }.count
}

try measure(part: .one) {
    print("Solution: \(try groundTilesInSmallestRectangleContainingAllElvesAfter(rounds: 10, from: .input))")
}

// MARK: - Part 2
func numberOfRoundsBeforeNoElfNeedsToMove(from input: String) throws -> Int {
    var grid = prepareGrid(from: input)
    grid.performRounds(Int.max, visualize: false)

    return grid.rounds
}

try measure(part: .two) {
    print("Solution: \(try numberOfRoundsBeforeNoElfNeedsToMove(from: .input))")
}
