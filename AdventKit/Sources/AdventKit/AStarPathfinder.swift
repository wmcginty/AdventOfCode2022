//
//  File.swift
//  
//
//  Created by Will McGinty on 12/20/22.
//

import Foundation
import Collections

public protocol Pathfinding {
    func neighbors(for point: Coordinate) -> [Coordinate]
    func costToMove(from: Coordinate, to: Coordinate) -> Int
    func distance(from: Coordinate, to: Coordinate) -> Int
}

public class AStarPathfinder<Map: Pathfinding> {

    private final class PathNode: Comparable, CustomStringConvertible {

        // MARK: - Coordinates
        let coordinate: Coordinate
        let parent: PathNode?

        let gScore: Int // Distance from start to node
        let hScore: Int // Heuristic distance from node to destination (using Manhattan distance)
        var fScore: Int { gScore + hScore }

        // MARK: - Initializer
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

        // MARK: - CustomStringConvertible
        var description: String {
            "pos=\(coordinate) g=\(gScore) h=\(hScore) f=\(fScore)"
        }
    }

    // MARK: - Properties
    public let map: Map

    // MARK: - Initializer
    public init(map: Map) {
        self.map = map
    }

    // MARK: - Interface
    public func shortestPath(from start: Coordinate, to end: Coordinate) -> [Coordinate]? {
        return shortestPath(from: start, to: [end])
    }

    public func shortestPath(from start: Coordinate, to ends: [Coordinate]) -> [Coordinate]? {
        var frontier = Heap<PathNode>()
        frontier.insert(PathNode(coordinate: start))

        var explored = [Coordinate: Int]()
        explored[start] = 0

        while let currentNode = frontier.popMin() {
            let currentCoordinate = currentNode.coordinate

            if ends.contains(currentCoordinate) {
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

                if explored[neighbor] == nil || explored[neighbor]! > newCost {
                    explored[neighbor] = newCost
                    let hScore = map.distance(from: currentCoordinate, to: neighbor)
                    let node = PathNode(coordinate: neighbor, parent: currentNode, moveCost: moveCost, hScore: hScore)
                    frontier.insert(node)
                }
            }
        }

        return nil
    }
}
