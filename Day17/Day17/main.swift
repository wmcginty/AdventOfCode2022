//
//  main.swift
//  Day17
//
//  Created by Will McGinty on 12/20/22.
//

import Foundation
import AdventKit

enum Jet: String {
    case left = "<"
    case right = ">"
}

struct Coordinate: Hashable {
    let x, y: Int

    enum Direction {
        case up, left, right, down
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

struct Piece: CaseIterable {

    let coordinates: [Coordinate] //top left = (0,0)
    let height: Int

    var left: Int { coordinates.map(\.x).min()! }
    var right: Int { coordinates.map(\.x).max()! }

    func moved(to direction: Coordinate.Direction, amount: Int = 1) -> Piece {
        Piece(coordinates: coordinates.map { $0.moved(in: direction, amount: amount) }, height: height)
    }

    static var allCases: [Piece] { return [.minus, .plus, .theEll, .pipe, .square] }
    static let minus = Piece(coordinates: [Coordinate(x: 0, y: 0),
                                           Coordinate(x: 1,y: 0),
                                           Coordinate(x: 2,y: 0),
                                           Coordinate(x: 3,y: 0)], height: 1)

    static let plus = Piece(coordinates: [Coordinate(x: 1,y: 0),
                                          Coordinate(x: 0,y: 1),
                                          Coordinate(x: 1,y: 1),
                                          Coordinate(x: 2,y: 1),
                                          Coordinate(x: 1,y: 2)], height: 3)

    static let theEll = Piece(coordinates: [Coordinate(x: 2,y: 0),
                                            Coordinate(x: 2,y: 1),
                                            Coordinate(x: 2,y: 2),
                                            Coordinate(x: 1,y: 2),
                                            Coordinate(x: 0,y: 2)], height: 3)

    static let pipe = Piece(coordinates: [Coordinate(x: 0,y: 0),
                                          Coordinate(x: 0,y: 1),
                                          Coordinate(x: 0,y: 2),
                                          Coordinate(x: 0,y: 3)], height: 4)

    static let square = Piece(coordinates: [Coordinate(x: 0,y: 0),
                                            Coordinate(x: 0,y: 1),
                                            Coordinate(x: 1,y: 0),
                                            Coordinate(x: 1,y: 1)], height: 2)
}

class Chamber {

    let width: Int
    private(set) var contents = [Coordinate: Bool]()
    private(set) var minimumY: Int
    private(set) var highYs: [Int]

    var accumulatedHeight: Int { -minimumY + 1 }

    init(chamberWidth: Int = 7) {
        width = chamberWidth
        minimumY = 1
        highYs = [Int](repeating: 1, count: width)
        Coordinate(x: -1, y: 1).line(to: .init(x: width, y: 1)).forEach {
            contents[$0] = true
        }
    }

    func add(_ piece: Piece) {
        piece.coordinates.forEach { p in
            contents[p] = true
            highYs[p.x] = min(highYs[p.x], p.y)
        }

        self.minimumY = min(minimumY, piece.coordinates.map(\.y).min()!)
    }

    func isPlacementPossible(for piece: Piece) -> Bool {
        piece.coordinates.allSatisfy { (0...width - 1) ~= $0.x && contents[$0] == nil }
    }

    // highest point in every column, normalized so that the lowest point is at y==0
    func skyline() -> [Coordinate] {
        var maxY = Int.min
        let points = (0...(width - 1)).map { x in
            let y = highYs[x]
            maxY = max(maxY, y)
            return Coordinate(x: x, y: y)
        }

        return points.map { $0.moved(in: .down, amount: -maxY) }
    }
}

class Tetris {

    struct Status: Hashable {
        let pieceIndex: Int
        let jetIndex: Int
        let skyline: [Coordinate]
    }

    let jets: [Jet]
    private(set) var jetIndex = 0

    private let pieces: [Piece] = Piece.allCases
    private(set) var pieceIndex = 0

    init(jets: [Jet]) {
        self.jets = jets
    }

    func play(times: Int, in chamber: Chamber) {
        for _ in 0..<times {
            play(in: chamber)
        }
    }

    func play(in chamber: Chamber, until: (Chamber) -> Bool) {
        while true {
            play(in: chamber)
            if until(chamber) {
                break
            }
        }
    }

    func play(in chamber: Chamber) {
        var piece = nextPiece()

        piece = piece
            .moved(to: .up, amount: chamber.accumulatedHeight + 2 + piece.height)
            .moved(to: .right, amount: 2)

        var fallen = false
        while !fallen {

            // jets
            let afterJet = piece.moved(to: nextJet(), amount: 1)
            if chamber.isPlacementPossible(for: afterJet) {
                piece = afterJet
            }

            // gravity
            let afterGravity = piece.moved(to: .down, amount: 1)
            if chamber.isPlacementPossible(for: afterGravity) {
                piece = afterGravity
            } else {
                fallen = true
            }
        }

        chamber.add(piece)
    }

    private func nextJet() -> Coordinate.Direction {
        defer { jetIndex = (jetIndex + 1) % jets.count }
        return jets[jetIndex] == .left ? .left : .right
    }

    private func nextPiece() -> Piece {
        defer { pieceIndex = (pieceIndex + 1) % pieces.count }
        return pieces[pieceIndex]
    }
}

// MARK: - Part 1
func heightOfTetris(after rocks: Int, from input: String) -> Int {
    let tetris = Tetris(jets: input.compactMap { Jet(rawValue: String($0)) })
    let chamber = Chamber()
    tetris.play(times: rocks, in: chamber)

    return chamber.accumulatedHeight
}

measure(part: .one) {
    print("Solution: \(heightOfTetris(after: 2022, from: .input))")

}

//// MARK: - Part 2
//func heightOfTetris(afterMany rocks: Int, from input: String) -> Int {
//    let tetris = Tetris(jets: input.compactMap { Jet(rawValue: String($0)) })
//    let chamber = Chamber()
//
//    var seen: [Tetris.Status: (Int, Int)] = [:]
//    tetris.play(in: chamber) { chamber in
//        let status = Tetris.Status(pieceIndex: tetris.pieceIndex, jetIndex: tetris.jetIndex, skyline: chamber.skyline())
//        if let (start, height) = seen[status] {
//
//        }
//
//        seen[status] = (0, chamber.accumulatedHeight)
//
//        return false
//    }
//
//}

//    func part2() -> Int {
//        jetIndex = 0
//        shapeIndex = 0
//        let rocks = 1_000_000_000_000 - 1
//        var seen = [Key: (Int, Int)]()
//
//        var pc = 0
//
//        var playfield = Chamber()
//        for block in 0..<Int.max {
//            playTetris(in: &playfield)
//            pc += 1
//            let key = Key(skyline: playfield.skyline(), shapeIndex: shapeIndex, jetIndex: jetIndex)
//            if let (start, height) = seen[key] {
//                let heightGain = playfield.accumulatedHeight - height
//                let loopLen = block - start
//                let loops = (rocks - start) / loopLen
//                let remainder = (rocks - start) - (loops * loopLen)
//                for _ in 0..<remainder {
//                    playTetris(in: &playfield)
//                    pc += 1
//                }
//
//                // -1 loops because we've stopped at the end of the first
//                return playfield.accumulatedHeight + ((loops - 1) * heightGain)
//            }
//            seen[key] = (block, playfield.accumulatedHeight)
//        }
//
//        return 0
//    }
