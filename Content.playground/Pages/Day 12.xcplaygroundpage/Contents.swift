//: [Previous](@previous)

import Foundation
import Collections

let inputURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let input = try String(String(contentsOf: inputURL!, encoding: String.Encoding.utf8).dropLast(1)) // Xcode forces an empty newline at the end of the file :(

let testInput = """
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
"""

struct Coordinate: Hashable, CustomStringConvertible {
    let x, y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    var description: String { return "\(x),\(y)" }

    func neighbors() -> [Coordinate] {
        return [.init(x: x + 1, y: y),
                .init(x: x - 1, y: y),
                .init(x: x, y: y + 1),
                .init(x: x, y: y - 1)]
    }

    func distance(to point: Coordinate) -> Int {
        return abs(x - point.x) + abs(y - point.y) // Manhattan distance
    }
}

protocol Pathfinding {
    func neighbors(for point: Coordinate) -> [Coordinate]
    func costToMove(from: Coordinate, to: Coordinate) -> Int
    func distance(from: Coordinate, to: Coordinate) -> Int
}

struct Map: Pathfinding {

    let map: [Coordinate: UInt8]
    let start: Coordinate
    let end: Coordinate

    init(map: [Coordinate: UInt8], start: Coordinate, end: Coordinate) {
        self.map = map
        self.start = start
        self.end = end
    }

    init(input: String) {
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

                map[coordinate] = copy.asciiValue!
            }
        }

        self.init(map: map, start: start, end: end)
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
        return from.distance(to: to)
    }
}

class AStarPathfinder<Map: Pathfinding> {

    private final class PathNode: Comparable, CustomDebugStringConvertible {
        let coordinate: Coordinate
        let parent: PathNode?
        
        let gScore: Int // Distance from start to node
        let hScore: Int // Heuristic distance from node to destination (using Manhattan distance)
        var fScore: Int { gScore + hScore }

        init(coordinate: Coordinate, parent: PathNode? = nil, moveCost: Int = 0, hScore: Int = 0) {
            self.coordinate = coordinate
            self.parent = parent
            self.gScore = (parent?.gScore ?? 0) + moveCost
            self.hScore = hScore
        }

        static func == (lhs: PathNode, rhs: PathNode) -> Bool {
            lhs.coordinate == rhs.coordinate
        }

        static func < (lhs: PathNode, rhs: PathNode) -> Bool {
            lhs.fScore < rhs.fScore
        }

        var debugDescription: String {
            "pos=\(coordinate) g=\(gScore) h=\(hScore) f=\(fScore)"
        }
    }

    private let map: Map

    init(map: Map) {
        self.map = map
    }

    func shortestPath(from start: Coordinate, to destination: Coordinate) -> [Coordinate] {
        var frontier = Heap<PathNode>()
        frontier.insert(PathNode(coordinate: start))

        var explored = [Coordinate: Int]()
        explored[start] = 0

        while let currentNode = frontier.popMin() {
            let currentCoordinate = currentNode.coordinate

            if currentCoordinate == destination {
                var result = [Coordinate]()
                var node: PathNode? = currentNode
                while let n = node {
                    result.append(n.coordinate)
                    node = n.parent
                }
                return Array(result.reversed().dropFirst())
            }

            for neighbor in map.neighbors(for: currentCoordinate) {
                let moveCost = map.costToMove(from: currentCoordinate, to: neighbor)
                let newCost = currentNode.gScore + moveCost

                if explored[neighbor] == nil || newCost <= explored[neighbor]! {
                    explored[neighbor] = newCost
                    let hScore = map.distance(from: currentCoordinate, to: neighbor)
                    let node = PathNode(coordinate: neighbor, parent: currentNode, moveCost: moveCost, hScore: hScore)
                    frontier.insert(node)
                }
            }
        }

        return []
    }
}

// MARK: - Part 1
func countOfShortestPath(input: String) -> Int {
    let heightMap = Map(input: input)
    let pathfinder = AStarPathfinder(map: heightMap)
    let shortestPath = pathfinder.shortestPath(from: heightMap.start, to: heightMap.end)
    return shortestPath.count
}

print("Part 1: \(countOfShortestPath(input: input))")


// MARK: - Part 2
func countOfShortestPathFromBottomToEnd(input: String) -> Int {
    let heightMap = Map(input: input)
    let pathfinder = AStarPathfinder(map: heightMap)

    return heightMap.map
        .filter { $0.value == Character("a").asciiValue! }
        .lazy
        .map { pathfinder.shortestPath(from: $0.key, to: heightMap.end).count }
        .filter { $0 > 0 }
        .min() ?? 0
}

print("Part 2: \(countOfShortestPathFromBottomToEnd(input: input))")

//: [Next](@next)
