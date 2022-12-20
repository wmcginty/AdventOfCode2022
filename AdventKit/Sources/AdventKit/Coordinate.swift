//
//  Coordinate.swift
//  
//
//  Created by Will McGinty on 12/20/22.
//

import Foundation

public struct Coordinate: Hashable, CustomStringConvertible {

    // MARK: - Coordinate.Direction
    public enum Direction: CaseIterable {
        case up, down, left, right
    }

    // MARK: - Properties
    public let x, y: Int

    // MARK: - Initializer
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    // MARK: - CustomStringConvertible
    public var description: String { return "\(x),\(y)" }
}

// MARK: - Distance and Movement
public extension Coordinate {

    func manhattanDistance(to point: Coordinate) -> Int {
        return abs(x - point.x) + abs(y - point.y)
    }

    func moved(in direction: Direction, amount: Int) -> Coordinate {
        switch direction {
        case .up: return Coordinate(x: x, y: y - amount)
        case .left: return Coordinate(x: x - amount, y: y)
        case .right: return Coordinate(x: x + amount, y: y)
        case .down: return Coordinate(x: x, y: y + amount)
        }
    }

    func line(to end: Coordinate) -> [Coordinate] {
        let dX = (end.x - x).signum()
        let dY = (end.y - y).signum()
        let range = max(abs(x - end.x), abs(y - end.y))
        return (0..<range).map { Coordinate(x: x + dX * $0, y: y + dY * $0) }
    }
}

// MARK: Coordinate + Neighbors
public extension Coordinate {

    func isAdjacent(to other: Coordinate) -> Bool {
        return abs(x - other.x) <= 1 && abs(y - other.y) <= 1
    }

    func neighbor(in direction: Direction) -> Coordinate {
        switch direction {
        case .up: return .init(x: x, y: y - 1)
        case .down: return .init(x: x, y: y + 1)
        case .left: return .init(x: x - 1, y: y)
        case .right: return .init(x: x + 1, y: y)
        }
    }

    func neighbors(in directions: [Direction] = Direction.allCases) -> [Coordinate] {
        return directions.map(neighbor(in:))
    }
}
