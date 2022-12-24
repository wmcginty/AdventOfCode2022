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
    let endPosition: Coordinate

    // MARK: - Initializer
    init(elements: [[Content]], blizzards: Set<Blizzard>) {
        self.blizzards = blizzards
        self.elements = elements

        let startX = elements[0].firstIndex(of: .floor)!
        let endX = elements[elements.count - 1].lastIndex(of: .floor)!

        self.player = .init(x: startX, y: 0)
        self.endPosition = .init(x: endX, y: elements.count - 1)
    }

    init(elements: [[Content]], blizzards: Set<Blizzard>, player: Coordinate, endPosition: Coordinate) {
        self.blizzards = blizzards
        self.elements = elements
        self.player = player
        self.endPosition = endPosition
    }

    // MARK: - Interface
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

        return Valley(elements: elements, blizzards: updatedBlizzards, player: player, endPosition: endPosition)
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
//        var valley: Valley
        var player: Coordinate
        var endPosition: Coordinate
        var stepsTaken: Int
    }

    let startingValleyState: Valley
    let possibleBlizzardStates: Int
    private var blizzardStateCache: [Int: Set<Valley.Blizzard>] = [:]

    init(startingValleyState: Valley) {
        self.startingValleyState = startingValleyState
        self.possibleBlizzardStates = (startingValleyState.elements.count - 1).lcm(with: (startingValleyState.elements[0].count - 1))
    }

    func updateBlizzards(after state: State) -> Set<Valley.Blizzard> {
        // The blizzards repeat themselves after LCM(w, h) moves
        print("lcm: \(possibleBlizzardStates)")
        let updatedTime = (state.stepsTaken + 1) % possibleBlizzardStates

        if let blizzards = blizzardStateCache[updatedTime] {
            return blizzards
        }

        let updated = state.valley.movingBlizzards().blizzards
        blizzardStateCache[updatedTime] = updated

        return updated
    }

    func minimumStepsToEndPosition() -> Int {
        var best = Int.max
        let start = State(valley: startingValleyState, stepsTaken: 0)
        var deque = Deque([start])

        var seen = Set<State>()
        while let state = deque.popFirst() {
            // If we've reached the end position (and we assume we haven't broken any rules) we're done
            if state.valley.player.coordinate == state.valley.endPosition {
                best = min(best, state.stepsTaken)
                print("Best: \(best)")
                continue
            }

            if seen.contains(state) {
                continue
            }
            seen.insert(state)

            if state.valley.player.coordinate != state.valley.endPosition && state.stepsTaken > best {
                continue
            }

            let updatedValley = Valley(elements: state.valley.elements, blizzards: updateBlizzards(after: state), player: state.valley.player, endPosition: state.valley.endPosition)

            if !updatedValley.blizzards.contains(where: { $0.coordinate == updatedValley.player.coordinate }) {
                // if we wait here, we don't get hit by a blizzard. this is viable
                deque.append(.init(valley: updatedValley, stepsTaken: state.stepsTaken + 1))
            }

            var availableDirections: [Coordinate.Direction] = []
            if updatedValley.player.coordinate.y > 0 {
                availableDirections.append(.north)
            }

            if updatedValley.player.coordinate.y < updatedValley.elements.count {
                availableDirections.append(.south)
            }

            if updatedValley.player.coordinate.x > 0 {
                availableDirections.append(.west)
            }

            if updatedValley.player.coordinate.x < updatedValley.elements[0].count {
                availableDirections.append(.east)
            }

            for direction in availableDirections {
                let moved = updatedValley.player.coordinate.moved(in: direction, amount: 1)
                if !updatedValley.blizzards.contains(where: { $0.coordinate == moved }) && updatedValley.element(at: moved) != .wall {
                    // if we move 1 in <direction>, we don't get hit by a blizzard. this is viable.
                    deque.append(.init(valley: .init(elements: updatedValley.elements, blizzards: updatedValley.blizzards,
                                                     player: .init(coordinate: moved), endPosition: updatedValley.endPosition),
                                       stepsTaken: state.stepsTaken + 1))
                }
            }
        }

        print(blizzardStateCache.count)
        return best
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
    return solver.minimumStepsToEndPosition()
}


try measure(part: .one) {
    print("Solution: \(try part1(from: .input))") //334, 150s
}

// MARK: - Part 2
func part2(from input: String) throws -> Int {
    return 0
}

try measure(part: .two) {
    print("Solution: \(try part2(from: .input))")
}

// While I'm not thrilled with my implementation, I'm pleased that I had the right approach from the outset. In short, precompute the locations of the blizzards for times up to some reasonable value (1000). Th

// The blizzard map repeats itself after LCM(n, m) moves, where LCM = lowest common multiple and n, m are the height and width of the inner box.

// the map repeats, so in theory you can cache (DP) every possible map
