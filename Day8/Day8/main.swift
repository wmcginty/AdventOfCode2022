//
//  main.swift
//  Day8
//
//  Created by Will McGinty on 12/19/22.
//

import Foundation

struct Grid: CustomStringConvertible {

    // MARK: - Subtypes
    struct Coordinate: CustomStringConvertible {
        let x, y: Int

    
        var description: String {
            return "(\(x), \(y))"
        }
    }

    // MARK: - Properties
    let elements: [[Int]]

    // MARK: - Interface
    var allCoordinates: [Coordinate] {
        return (0..<elements.count).flatMap { row in
            return (0..<elements[0].count).map { column in
                return .init(x: column, y: row)
            }
        }
    }

    var visibleTrees: Int { return allCoordinates.map { isTreeVisible(at: $0) }.filter { $0 }.count }
    var highestScenicScore: Int { return allCoordinates.map { scenicScore(at: $0) }.max() ?? 0 }

    func trees(_ direction: Direction, of point: Coordinate) -> any Collection<Int> {
        switch direction {
        case .east: return elements[point.y][(point.x + 1)...]
        case .west: return elements[point.y][..<point.x]
        case .north: return (0..<point.y).map { elements[$0][point.x] }
        case .south: return ((point.y + 1)..<elements.count).map { elements[$0][point.x] }
        }
    }

    func scenicScore(_ direction: Direction, of point: Coordinate) -> Int {
        let thisTree = elements[point.y][point.x]
        let treesInDirection = trees(direction, of: point)
        let fullyVisibleTrees = direction == .north || direction == .west ? treesInDirection.reversed().prefix { $0 < thisTree } : treesInDirection.prefix { $0 < thisTree }

        return fullyVisibleTrees.count == treesInDirection.count ? fullyVisibleTrees.count : fullyVisibleTrees.count + 1
    }

    func isTreeVisible(at point: Coordinate) -> Bool {
        if point.x == 0 || point.x == elements[0].count || point.y == 0 || point.y == elements.count {
            return true
        }

        let thisTree = elements[point.y][point.x]
        if trees(.north, of: point).allSatisfy({ $0 < thisTree }) {
            return true
        }

        if trees(.east, of: point).allSatisfy({ $0 < thisTree }) {
            return true
        }

        if trees(.south, of: point).allSatisfy({ $0 < thisTree }) {
            return true
        }

        if trees(.west, of: point).allSatisfy({ $0 < thisTree }) {
            return true
        }

        return false
    }

    func scenicScore(at point: Coordinate) -> Int {
        return [
            scenicScore(.north, of: point),
            scenicScore(.east, of: point),
            scenicScore(.south, of: point),
            scenicScore(.west, of: point)
        ].reduce(1, *)
    }

    var description: String {
        var result = ""
        for row in elements {
            result += row.map(String.init).joined() + "\n"
        }

        return result
    }

    // MARK: - Method 2 That May or May Not Be Better At Part 1
    enum Direction {
        case north, south, east, west
    }

    func coordinateMap(for direction: Direction) -> [[Coordinate]] {
        switch direction {
        case .north, .west:
            return (0..<elements.count).map { row in
                return (0..<elements[0].count).map { column in
                    return .init(x: column, y: row)
                }
            }

        case .south:
            return (0..<elements.count).map { row in
                return (0..<elements[0].count).map { column in
                    return .init(x: column, y: elements.count - 1 - row)
                }
            }

        case .east:
            return (0..<elements.count).map { row in
                return (0..<elements[0].count).map { column in
                    return .init(x: elements[0].count - 1 - column, y: row)
                }
            }
        }
    }

    func visibleTreeMap(from direction: Direction) -> [[Bool]] {
        var highest = Array(repeating: 0, count: elements.count)
        let map = coordinateMap(for: direction).map { coordinateRow in
            return coordinateRow.map { coordinate in
                let value = elements[coordinate.y][coordinate.x]

                defer {
                    if value > highest[direction == .north || direction == .south ? coordinate.x : coordinate.y] {
                        highest[direction == .north || direction == .south ? coordinate.x : coordinate.y] = value
                    }
                }

                if direction == .north && coordinate.y == 0 {
                    return true
                } else if direction == .south && coordinate.y == elements.count - 1 {
                    return true
                } else if direction == .west && coordinate.x == 0 {
                    return true
                } else if direction == .east && coordinate.x == elements[0].count - 1 {
                    return true
                } else if value > highest[direction == .north || direction == .south ? coordinate.x : coordinate.y] {
                    return true
                }

                return false
            }
        }

        if direction == .north || direction == .west {
            return map
        } else if direction == .south {
            return map.reversed()
        } else {
            return map.map { $0.reversed() }
        }
    }

    var betterVisibleTreeCount: Int {
        var count = 0

        // If I pass in the previous map, does the short circuiting actually improve the speed?
        let northMap = visibleTreeMap(from: .north)
        let southMap = visibleTreeMap(from: .south)
        let eastMap = visibleTreeMap(from: .east)
        let westMap = visibleTreeMap(from: .west)

        for row in (0..<northMap.count) {
            for column in (0..<northMap[0].count) {
                if northMap[row][column] || southMap[row][column] || eastMap[row][column] || westMap[row][column] {
                    count += 1
                }
            }
        }

        return count
    }
}

// MARK: - Helper
func treeGrid(from input: String) -> Grid {
    return Grid(elements: input.components(separatedBy: .newlines)
        .map { $0.compactMap { Int(String($0)) } })
}

let grid = treeGrid(from: .input)

// MARK: - Part 1
print("Method 1")
let s1 = Date.now
print(grid.visibleTrees)
print("Elapsed: ", Date.now.timeIntervalSince(s1))

print()

print("Method 2")
let s2 = Date.now
print(grid.betterVisibleTreeCount)
print("Elapsed: ", Date.now.timeIntervalSince(s2))

// MARK: - Part 2
print()
print(grid.highestScenicScore)

