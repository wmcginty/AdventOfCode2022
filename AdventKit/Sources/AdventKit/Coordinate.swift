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
        case north, northEast, east, southEast, south, southWest, west, northWest

        public var isNorthOrSouth: Bool { return self == .north || self == .south }
        public var isEastOrWest: Bool { return self == .east || self == .west }

        static let cardinal: [Direction] = [.north, .south, .east, .west]
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
        case .north: return Coordinate(x: x, y: y - amount)
        case .northEast: return Coordinate(x: x + amount, y: y - amount)
        case .east: return Coordinate(x: x + amount, y: y)
        case .southEast: return Coordinate(x: x + amount, y: y + amount)
        case .south: return Coordinate(x: x, y: y + amount)
        case .southWest: return Coordinate(x: x - amount, y: y + amount)
        case .west: return Coordinate(x: x - amount, y: y)
        case .northWest: return Coordinate(x: x - amount, y: y - amount)
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
        case .north: return Coordinate(x: x, y: y - 1)
        case .northEast: return Coordinate(x: x + 1, y: y - 1)
        case .east: return Coordinate(x: x + 1, y: y)
        case .southEast: return Coordinate(x: x + 1, y: y + 1)
        case .south: return Coordinate(x: x, y: y + 1)
        case .southWest: return Coordinate(x: x - 1, y: y + 1)
        case .west: return Coordinate(x: x - 1, y: y)
        case .northWest: return Coordinate(x: x - 1, y: y - 1)
        }
    }

    func neighbors(in directions: [Direction] = Direction.allCases) -> [Coordinate] {
        return directions.map(neighbor(in:))
    }
}
