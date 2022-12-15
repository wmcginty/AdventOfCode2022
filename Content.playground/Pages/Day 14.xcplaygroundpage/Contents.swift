//: [Previous](@previous)

import Foundation
import Algorithms
import Parsing

let inputURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let input = try String(String(contentsOf: inputURL!, encoding: String.Encoding.utf8).dropLast(1)) // Xcode forces an empty newline at the end of the file :(

struct Coordinate: Hashable {
    let x,y: Int
}

struct Path {
    let coordinates: [Coordinate]

    var allCoordinates: Set<Coordinate> {
        var result: Set<Coordinate> = []
        for (lineStart, lineEnd) in coordinates.adjacentPairs() {
            let lineXRange = min(lineStart.x, lineEnd.x)...max(lineStart.x, lineEnd.x)
            let lineYRange = min(lineStart.y, lineEnd.y)...max(lineStart.y, lineEnd.y)

            for x in lineXRange {
                for y in lineYRange {
                    result.insert(.init(x: x, y: y))
                }
            }
        }

        return result
    }

    func isOccupying(coordinate: Coordinate) -> Bool {
        for (lineStart, lineEnd) in coordinates.adjacentPairs() {
            let lineXRange = min(lineStart.x, lineEnd.x)...max(lineStart.x, lineEnd.x)
            let lineYRange = min(lineStart.y, lineEnd.y)...max(lineStart.y, lineEnd.y)

            if lineXRange.contains(coordinate.x) && lineYRange.contains(coordinate.y) {
                return true
            }
        }

        return false
    }
}

struct Cave {

    enum Bottom {
        case void, floor
    }

    private let bottomY: Int
    var sandEntry: Coordinate
    var bottom: Bottom

    var fallenSandCount: Int = 0
    var obstacles: Set<Coordinate> = []

    // MARK: - Initializer
    init(paths: [Path], sandEntry: Coordinate, bottom: Bottom = .void) {
        self.bottomY = paths.flatMap(\.coordinates).map(\.y).max()! + 2
        self.sandEntry = sandEntry
        self.bottom = bottom

        if bottom == .floor {
            let floorPath = Path(coordinates: [.init(x: paths.flatMap(\.coordinates).map(\.x).min()! - 1000,
                                                     y: bottomY),
                                               .init(x: paths.flatMap(\.coordinates).map(\.x).max()! + 1000,
                                                     y: bottomY)])
            self.obstacles = Set(paths.flatMap(\.allCoordinates)).union(floorPath.allCoordinates)
        } else {
            self.obstacles = Set(paths.flatMap(\.allCoordinates))
        }
    }

    func hasSandHitVoid(at coordinate: Coordinate) -> Bool {
        return coordinate.y >= bottomY && bottom == .void
    }

    func sandCanFall(to coordinate: Coordinate) -> Bool {
        return !obstacles.contains(coordinate)
    }

    mutating func performNewSandFall() -> Bool {
        var sand = sandEntry

        while !hasSandHitVoid(at: sand) && !obstacles.contains(sandEntry) {
            let fallDown = Coordinate(x: sand.x, y: sand.y + 1)
            let fallDiagonalLeft = Coordinate(x: sand.x - 1, y: sand.y + 1)
            let fallDiagonalRight = Coordinate(x: sand.x + 1, y: sand.y + 1)
            if sandCanFall(to: fallDown) {
                sand = fallDown
            } else if sandCanFall(to: fallDiagonalLeft) {
                sand = fallDiagonalLeft
            } else if sandCanFall(to: fallDiagonalRight) {
                sand = fallDiagonalRight
            } else {
                obstacles.insert(sand)
                fallenSandCount += 1
                return true
            }
        }

        return false
    }

    mutating func performSandFallsUntilVoid() {
        var hasNotHitVoid = true
        while hasNotHitVoid {
            hasNotHitVoid = performNewSandFall()
        }
    }
}

let pathParser = Parse {
    Many {
        Parse {
            Int.parser()
            ","
            Int.parser()
        }.map { Coordinate(x: $0.0, y: $0.1) }
    } separator: {
        " -> "
    }
}.map { Path(coordinates: $0) }

// MARK: - Part 1
func unitsOfSand(from input: String) throws -> Int {
    let paths = try Many { pathParser } separator: { "\n" }.parse(input)

    var cave = Cave(paths: paths, sandEntry: .init(x: 500, y: 0), bottom: .void)
    cave.performSandFallsUntilVoid()

    return cave.fallenSandCount
}

print("Part 1: \(try unitsOfSand(from: input))")


// MARK: - Part 2
func unitsOfSandUntilEntryBlocked(from input: String) throws -> Int {
    let paths = try Many { pathParser } separator: { "\n" }.parse(input)

    var cave = Cave(paths: paths, sandEntry: .init(x: 500, y: 0), bottom: .floor)
    cave.performSandFallsUntilVoid()

    return cave.fallenSandCount
}

print("Part 2: \(try unitsOfSandUntilEntryBlocked(from: input))")

//: [Next](@next)
