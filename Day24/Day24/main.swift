//
//  main.swift
//  Day24
//
//  Created by Will McGinty on 12/23/22.
//

import Foundation
import AdventKit
import Algorithms
import Collections
import Parsing

extension Coordinate.Direction: CustomStringConvertible {

    init?(character: Character) {
        switch character {
        case "^": self = .north
        case "v": self = .south
        case ">": self = .east
        case "<": self = .west
        default: return nil
        }
    }

    public var description: String {
        switch self {
        case .north: return "^"
        case .south: return "v"
        case .east: return ">"
        case .west: return "<"
        default: return ""
        }
    }
}

class Storm {

    struct Blizzard: Hashable {
        var coordinate: Coordinate
        let direction: Coordinate.Direction
    }

    // MARK: - Properties
    let initialBlizzards: Set<Blizzard>
    let valley: Valley

    // MARK: - Initializer
    init(initialBlizzards: Set<Blizzard>, valley: Valley) {
        self.initialBlizzards = initialBlizzards
        self.valley = valley
    }

    // MARK: - Interface
    func moveBlizzards(_ blizzards: Set<Blizzard>) -> Set<Blizzard> {
        var updatedBlizzards: Set<Blizzard> = []
        for var blizzard in blizzards {
            // TODO: You can definitely use some combinatino of modulo here to skip multiple minutes in one go
            let moved = blizzard.coordinate.moved(in: blizzard.direction, amount: 1)
            let wrapAround = wrapAroundCoordinate(for: blizzard)
            blizzard.coordinate = valley.element(at: moved) == .wall ? wrapAround : moved

            updatedBlizzards.insert(blizzard)
        }

        return updatedBlizzards
    }

    // MARK: - Helper
    func wrapAroundCoordinate(for blizzard: Blizzard) -> Coordinate {
        switch blizzard.direction {
        case .north:
            let firstInBounds = valley.elements.indices.lastIndex(where: { valley.elements[$0][blizzard.coordinate.x] != .wall })!
            return .init(x: blizzard.coordinate.x, y: firstInBounds)

        case .south:
            let firstInBounds = valley.elements.indices.firstIndex(where: { valley.elements[$0][blizzard.coordinate.x] != .wall })!
            return .init(x: blizzard.coordinate.x, y: firstInBounds)

        case .east:
            let firstInBounds = valley.elements[blizzard.coordinate.y].firstIndex(where: { $0 != .wall })!
            return .init(x: firstInBounds, y: blizzard.coordinate.y)

        case .west:
            let firstInBounds = valley.elements[blizzard.coordinate.y].lastIndex(where: { $0 != .wall })!
            return .init(x: firstInBounds, y: blizzard.coordinate.y)

        default: return blizzard.coordinate
        }
    }
}

struct Valley: Hashable {

    enum Content: Equatable, CustomStringConvertible {
        case floor
        case wall

        var description: String {
            switch self {
            case .floor: return "."
            case .wall: return "#"
            }
        }
    }

    // MARK: - Properties
    let elements: [[Content]]
    let entryPosition: Coordinate
    let exitPosition: Coordinate

    // MARK: - Initializer
    init(elements: [[Content]]) {
        self.elements = elements
        let startX = elements[0].firstIndex(of: .floor)!
        self.entryPosition = .init(x: startX, y: 0)

        let endX = elements[elements.count - 1].lastIndex(of: .floor)!
        self.exitPosition = .init(x: endX, y: elements.count - 1)
    }

    init(elements: [[Content]], entryPosition: Coordinate, exitPosition: Coordinate) {
        self.elements = elements
        self.entryPosition = entryPosition
        self.exitPosition = exitPosition
    }

    // MARK: - Interface
    var floorWidth: Int { return elements[0].count - 2 }
    var floorHeight: Int { return elements.count - 2 }

    func element(at coordinate: Coordinate) -> Content {
        return elements[coordinate.y][coordinate.x]
    }

    func description(with blizzards: Set<Storm.Blizzard>, andPlayer player: Coordinate) -> String {
        var result: String = ""
        for row in elements.indices {
            for col in elements[row].indices {
                let thisPosition = Coordinate(x: col, y: row)
                let blizzardsAtThisPosition = blizzards.filter { $0.coordinate == thisPosition }

                if player == thisPosition {
                    result += "E"
                } else if blizzardsAtThisPosition.count > 1 {
                    result += blizzardsAtThisPosition.count.formatted()
                } else if blizzardsAtThisPosition.count == 1 {
                    result += blizzardsAtThisPosition.first!.direction.description
                } else {
                    result += element(at: thisPosition).description
                }
            }

            result += "\n"
        }

        return result
    }
}

class Solver {

    struct State: Hashable {
        var player: Coordinate
        var startPosition: Coordinate
        var endPosition: Coordinate
        var trips: Int
        var time: Int
    }

    // MARK: - Properties
    let valley: Valley
    let storm: Storm

    private let possibleBlizzardStates: Int
    private var blizzardStateCache: [Int: Set<Storm.Blizzard>] = [:]

    init(valley: Valley, storm: Storm) {
        self.valley = valley
        self.storm = storm
        self.possibleBlizzardStates = valley.floorWidth.lcm(with: valley.floorHeight)

        precomputeBlizzardStates()
    }

    func precomputeBlizzardStates() {
        var currentBlizzards = storm.initialBlizzards
        blizzardStateCache[0] = currentBlizzards

        for i in 1..<possibleBlizzardStates {
            currentBlizzards = storm.moveBlizzards(currentBlizzards)
            blizzardStateCache[i] = currentBlizzards
        }

        print("Done pre-computing \(possibleBlizzardStates) blizzard states.")
    }

    func blizzards(for time: Int) -> Set<Storm.Blizzard> {
        return blizzardStateCache[time % possibleBlizzardStates]!
    }

    func availableDirectionsForPlayer(at coordinate: Coordinate) -> [Coordinate.Direction] {
        let maxX = valley.elements[0].count
        let maxY = valley.elements.count

        var availableDirections: [Coordinate.Direction] = []

        if coordinate.y > 0 { availableDirections.append(.north) }
        if coordinate.y < maxY - 1 { availableDirections.append(.south) }

        if coordinate.x > 0 { availableDirections.append(.west) }
        if coordinate.x < maxX - 1 { availableDirections.append(.east) }

        return availableDirections
    }

    func minimumStepsAcrossValley(times: Int = 1) -> Int {
        var best = Int.max
        let start = State(player: valley.entryPosition, startPosition: valley.entryPosition, endPosition: valley.exitPosition, trips: 1, time: 0)
        var deque = Deque([start])

        var seen = Set<State>()
        while let state = deque.popFirst() {
            // If we've reached the end position (and we assume we haven't broken any rules) we're done
            if state.player == state.endPosition {
                if state.trips == times {
                    best = min(best, state.time)
                    continue
                }

                deque.append(.init(player: state.player, startPosition: state.endPosition, endPosition: state.startPosition, trips: state.trips + 1, time: state.time))
                continue
            }

            // If we've seen this state, or we've already past the best time, we can stop
            if seen.contains(state) {
                continue
            }

            if state.time >= best {
                continue
            }

            if state.time + state.player.manhattanDistance(to: state.endPosition) >= best {
                continue
            }

            seen.insert(state)

            // Ask for the blizzards at the NEXT state. We move simultaneously with them, so we want to know where they are going, not where they are now.
            let blizzards = blizzards(for: state.time + 1)

            if !blizzards.contains(where: { $0.coordinate == state.player }) {
                // if we wait here, we won't get hit by a blizzard. this is viable
                deque.append(.init(player: state.player, startPosition: state.startPosition, endPosition: state.endPosition, trips: state.trips, time: state.time + 1))
            }

            for direction in availableDirectionsForPlayer(at: state.player) {
                let moved = state.player.moved(in: direction, amount: 1)
                if !blizzards.contains(where: { $0.coordinate == moved }) && valley.element(at: moved) != .wall {
                    // if we move 1 in <direction>, we won't get hit by a blizzard. this is viable.
                    deque.append(.init(player: moved, startPosition: state.startPosition, endPosition: state.endPosition, trips: state.trips, time: state.time + 1))
                }
            }
        }

        return best
    }
}

func prepareGrid(from input: String) -> ([[Valley.Content]], Set<Storm.Blizzard>) {
    var blizzards: Set<Storm.Blizzard> = []
    let grid: [[Valley.Content]] = input.components(separatedBy: .newlines).indexed().map { (row, line) in
        return line.indexed().map { (col, character) in

            switch character {
            case "#": return .wall
            case ".": return .floor
            default:
                if let direction = Coordinate.Direction(character: character) {
                    blizzards.insert(.init(coordinate: .init(x: line.distance(from: line.startIndex, to: col), y: row), direction: direction))
                }

                return .floor
            }
        }
    }

    return (grid, blizzards)
}

// MARK: - Part 1
func part1(from input: String) throws -> Int {
    let (gridContents, blizzards) = prepareGrid(from: input)
    let valley = Valley(elements: gridContents)
    let solver = Solver(valley: valley, storm: .init(initialBlizzards: blizzards, valley: valley))

    return solver.minimumStepsAcrossValley()
}

try measure(part: .one) {
    print("Solution: \(try part1(from: .input))") //334, 1.8s
}

// MARK: - Part 2
func part2(from input: String) throws -> Int {
    let (gridContents, blizzards) = prepareGrid(from: input)
    let valley = Valley(elements: gridContents)
    let solver = Solver(valley: valley, storm: .init(initialBlizzards: blizzards, valley: valley))

    return solver.minimumStepsAcrossValley(times: 3) //934, 14.6s
}

try measure(part: .two) {
    print("Solution: \(try part2(from: .input))")
}
