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

extension Coordinate.Direction {

    init(string: String) {
        switch string {
        case "^": self = .north
        case "v": self = .south
        case ">": self = .east
        case "<": self = .west
        default: fatalError("invalid direction")
        }
    }

    var rawValue: String {
        switch self {
        case .north: return "^"
        case .south: return "v"
        case .east: return ">"
        case .west: return "<"
        default: fatalError("invalid direction")
        }
    }
}

struct Valley: Hashable, CustomStringConvertible {

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

    struct Blizzard: Hashable {
        var coordinate: Coordinate
        let direction: Coordinate.Direction
    }

    // MARK: - Properties
    let elements: [[Content]]
    let blizzards: Set<Blizzard>
    let player: Coordinate
    let startPosition: Coordinate
    let endPosition: Coordinate

    // MARK: - Initializer
    init(elements: [[Content]], blizzards: Set<Blizzard>) {
        self.blizzards = blizzards
        self.elements = elements

        let startX = elements[0].firstIndex(of: .floor)!
        let endX = elements[elements.count - 1].lastIndex(of: .floor)!

        self.player = .init(x: startX, y: 0)
        self.startPosition = .init(x: startX, y: 0)
        self.endPosition = .init(x: endX, y: elements.count - 1)
    }

    init(elements: [[Content]], blizzards: Set<Blizzard>, player: Coordinate, startPosition: Coordinate, endPosition: Coordinate) {
        self.blizzards = blizzards
        self.elements = elements
        self.player = player
        self.startPosition = startPosition
        self.endPosition = endPosition
    }

    // MARK: - Interface
    var width: Int { return elements[0].count - 2 }
    var height: Int { return elements.count - 2 }

    func element(at coordinate: Coordinate) -> Content {
        return elements[coordinate.y][coordinate.x]
    }

    func movingBlizzards() -> Valley {
        func wrapAroundCoordinate(for blizzard: Blizzard) -> Coordinate {
            switch blizzard.direction {
            case .north:
                let firstInBounds = elements.indices.lastIndex(where: { elements[$0][blizzard.coordinate.x] != .wall })!
                return .init(x: blizzard.coordinate.x, y: firstInBounds)

            case .south:
                let firstInBounds = elements.indices.firstIndex(where: { elements[$0][blizzard.coordinate.x] != .wall })!
                return .init(x: blizzard.coordinate.x, y: firstInBounds)

            case .east:
                let firstInBounds = elements[blizzard.coordinate.y].firstIndex(where: { $0 != .wall })!
                return .init(x: firstInBounds, y: blizzard.coordinate.y)

            case .west:
                let firstInBounds = elements[blizzard.coordinate.y].lastIndex(where: { $0 != .wall })!
                return .init(x: firstInBounds, y: blizzard.coordinate.y)

            default: return blizzard.coordinate
            }
        }

        var updatedBlizzards: Set<Blizzard> = []
        for var blizzard in blizzards {
            let moved = blizzard.coordinate.moved(in: blizzard.direction, amount: 1)
            let wrapAround = wrapAroundCoordinate(for: blizzard)
            blizzard.coordinate = element(at: moved) == .wall ? wrapAround : moved
            updatedBlizzards.insert(blizzard)
        }

        return Valley(elements: elements, blizzards: updatedBlizzards, player: player, startPosition: startPosition, endPosition: endPosition)
    }

    // MARK: - CustomStringConvertible
    var description: String {
        var result: String = ""
        for row in elements.indices {
            for col in elements[row].indices {
                let blizzards = self.blizzards.filter { $0.coordinate == .init(x: col, y: row) }
                if player == .init(x: col, y: row) {
                    result += "E"
                } else if blizzards.count > 1 {
                    result += blizzards.count.formatted()
                } else if blizzards.count == 1 {
                    result += blizzards.first!.direction.rawValue
                } else {
                    result += elements[row][col].description
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

    let startingValleyState: Valley
    let possibleBlizzardStates: Int
    private var blizzardStateCache: [Int: Set<Valley.Blizzard>] = [:]

    init(startingValleyState: Valley) {
        self.startingValleyState = startingValleyState
        self.possibleBlizzardStates = (startingValleyState.width).lcm(with: startingValleyState.height)

        precomputeBlizzardStates()
        print("done precomputing blizzard states")
    }

    func precomputeBlizzardStates() {
        var valley = startingValleyState
        blizzardStateCache[0] = valley.blizzards

        for i in 1..<possibleBlizzardStates {
            valley = valley.movingBlizzards()
            blizzardStateCache[i] = valley.blizzards
        }
    }

    func blizzardState(for time: Int) -> Set<Valley.Blizzard> {
        return blizzardStateCache[time % possibleBlizzardStates]!
    }

    func minimumStepsAcrossValley(times: Int = 1) -> Int {
        var best = Int.max
        let start = State(player: startingValleyState.player, startPosition: startingValleyState.startPosition, endPosition: startingValleyState.endPosition, trips: 0, time: 0)
        var deque = Deque([start])

        let maxY = startingValleyState.elements.count
        let maxX = startingValleyState.elements[0].count

        var seen = Set<State>()
        while let state = deque.popFirst() {
            // If we've reached the end position (and we assume we haven't broken any rules) we're done
            if state.player == state.endPosition && state.trips == times - 1 {
                best = min(best, state.time)
                continue
            }

            if seen.contains(state) || state.time > best {
                continue
            }

            seen.insert(state)

            if state.player == state.endPosition && state.trips < times {
                print("trip done after \(state.time)")
                deque.append(.init(player: state.player, startPosition: state.endPosition, endPosition: state.startPosition, trips: state.trips + 1, time: state.time))
                continue
            }

            let blizzardState = blizzardState(for: state.time)
            if !blizzardState.contains(where: { $0.coordinate == state.player }) {
                // if we wait here, we don't get hit by a blizzard. this is viable
                deque.append(.init(player: state.player, startPosition: state.startPosition, endPosition: state.endPosition, trips: state.trips, time: state.time + 1))
            }

            var availableDirections: [Coordinate.Direction] = []
            if state.player.y > 0 {
                availableDirections.append(.north)
            }

            if state.player.y < maxY - 1 {
                availableDirections.append(.south)
            }

            if state.player.x > 0 {
                availableDirections.append(.west)
            }

            if state.player.x < maxX - 1 {
                availableDirections.append(.east)
            }

            for direction in availableDirections {
                let moved = state.player.moved(in: direction, amount: 1)
                if !blizzardState.contains(where: { $0.coordinate == moved }) && startingValleyState.element(at: moved) != .wall {
                    // if we move 1 in <direction>, we don't get hit by a blizzard. this is viable.
                    deque.append(.init(player: moved, startPosition: state.startPosition, endPosition: state.endPosition, trips: state.trips, time: state.time + 1))
                }
            }
        }

        return best - 1
    }
}

func prepareGrid(from input: String) -> ([[Valley.Content]], Set<Valley.Blizzard>) {
    var blizzards: Set<Valley.Blizzard> = []
    let grid: [[Valley.Content]] = input.components(separatedBy: .newlines).indexed().map { (row, line) in
        return line.indexed().map { (col, character) in

            switch character {
            case "#": return .wall
            case ".": return .floor
            default:
                blizzards.insert(.init(coordinate: .init(x: line.distance(from: line.startIndex, to: col), y: row), direction: .init(string: String(character))))
                return .floor
            }
        }
    }

    return (grid, blizzards)
}

// MARK: - Part 1
func part1(from input: String) throws -> Int {
    let (gridContents, blizzards) = prepareGrid(from: input)
    let valley = Valley(elements: gridContents, blizzards: blizzards)

    let solver = Solver(startingValleyState: valley)
    return solver.minimumStepsAcrossValley()
}

try measure(part: .one) {
    print("Solution: \(try part1(from: .input))") //334, 30s
}

//// MARK: - Part 2
//func part2(from input: String) throws -> Int {
//    let (gridContents, blizzards) = prepareGrid(from: input)
//    let valley = Valley(elements: gridContents, blizzards: blizzards)
//
//    let solver = Solver(startingValleyState: valley)
//    let trip1 = solver.minimumStepsAcrossValley()
//
//    let backSolver = Solver(startingValleyState: .init(elements: valley.elements, blizzards: solver.blizzardState(for: trip1), player: valley.endPosition, startPosition: valley.endPosition, endPosition: valley.startPosition))
//    let trip2 = backSolver.minimumStepsAcrossValley()
//
//    let forwardSolver = Solver(startingValleyState: .init(elements: valley.elements, blizzards: solver.blizzardState(for: trip1 + trip2), player: valley.startPosition, startPosition: valley.startPosition, endPosition: valley.endPosition))
//    let trip3 = forwardSolver.minimumStepsAcrossValley()
//
//    return trip1 + trip2 + trip3
//}
//
//try measure(part: .two) {
//    print("Solution: \(try part2(from: .input))")
//}

// While I'm not thrilled with my implementation, I'm pleased that I had the right approach from the outset. In short, precompute the locations of the blizzards for times up to some reasonable value (1000). Th

// The blizzard map repeats itself after LCM(n, m) moves, where LCM = lowest common multiple and n, m are the height and width of the inner box.

// the map repeats, so in theory you can cache (DP) every possible map
