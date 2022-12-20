//
//  main.swift
//  Day12
//
//  Created by Will McGinty on 12/19/22.
//

import Foundation
import AdventKit

struct Map: Pathfinding {

    let map: [Coordinate: UInt8]
    let start: Coordinate
    let end: Coordinate
    let reversed: Bool

    init(map: [Coordinate: UInt8], start: Coordinate, end: Coordinate, reversed: Bool) {
        self.map = map
        self.start = start
        self.end = end
        self.reversed = reversed
    }

    init(input: String, reversed: Bool = false) {
        var start = Coordinate(x: 0, y: 0)
        var end = Coordinate(x: 0, y: 0)
        var map = [Coordinate: UInt8]()

        for (y, line) in input.components(separatedBy: .newlines).enumerated() {
            for (x, character) in line.enumerated() {
                var copy = character
                let coordinate = Coordinate(x: x, y: y)

                if copy == "S" {
                    start = coordinate
                    copy = "a"
                } else if copy == "E" {
                    end = coordinate
                    copy = "z"
                }

                map[coordinate] = reversed ? ((122 - copy.asciiValue!) + 97) : copy.asciiValue!
            }
        }

        self.init(map: map, start: start, end: end, reversed: reversed)
    }

    var lowestElevation: UInt8 {
        let min = map.map(\.value).min()!
        return reversed ? ((122 - min) + 97) : min
    }

    func neighbors(for point: Coordinate) -> [Coordinate] {
        let currentHeight = map[point]! + 1
        return point.neighbors().filter {
            return map[$0].map { $0 <= currentHeight } ?? false
        }
    }

    func costToMove(from: Coordinate, to: Coordinate) -> Int {
        return 1
    }

    func distance(from: Coordinate, to: Coordinate) -> Int {
        return from.manhattanDistance(to: to)
    }
}

// MARK: - Part 1
func countOfShortestPath(input: String) -> Int? {
    let heightMap = Map(input: input, reversed: false)
    let pathfinder = AStarPathfinder(map: heightMap)
    let shortestPath = pathfinder.shortestPath(from: heightMap.start, to: [heightMap.end])
    return shortestPath?.count
}

measure(part: .one) {
    print("Solution: \(String(describing: countOfShortestPath(input: .input)))")
}

// MARK: - Part 2
func countOfShortestPathFromBottomToEnd(input: String) -> Int? {
    let heightMap = Map(input: input, reversed: true)
    let pathfinder = AStarPathfinder(map: heightMap)

    let destinations = heightMap.map.filter { $0.value == heightMap.lowestElevation }.map(\.key)
    return pathfinder.shortestPath(from: heightMap.end, to: destinations)?.count
}

measure(part: .two) {
    print("Solution: \(String(describing: countOfShortestPathFromBottomToEnd(input: .input)))")

}

