//
//  main.swift
//  Day16
//
//  Created by Will McGinty on 12/19/22.
//

import Foundation
import AdventKit
import Parsing
import Collections

struct Valve: Equatable {
    let name: String
    let flowRate: Int
    let connectedValveNames: [String]
}

struct State: Hashable {
    var flowReleased: Int
    var current: String
    var opened: Set<String>
    var otherPeople: Int
    var time: Int
}

let valveParser = Parse {
    "Valve "

    Prefix(while: { $0 != " " })

    " has flow rate="
    Int.parser()

    OneOf {
        "; tunnels lead to valves "
        "; tunnel leads to valve "
    }

    Many {
        Prefix(while: { $0 != "," && $0 != "\n" })
    } separator: { ", " }
}.map {
    Valve(name: String($0), flowRate: $1, connectedValveNames: $2.map(String.init))
}

let valvesParser = Many { valveParser } separator: { "\n" }

func maximumFlowReleased(using valves: [String: Valve], inTotalTime totalTime: Int, withOtherPeople count: Int) -> Int {
    var best = 0
    let start = State(flowReleased: 0, current: "AA", opened: [], otherPeople: count, time: totalTime)
    var deque = Deque([start])
    var seen = Set<State>()

    let allFlowingValves = Set(valves.values.filter { $0.flowRate > 0 }.map(\.name))

    while let status = deque.popFirst() {
        best = max(best, status.flowReleased)

        if status.time == 0 {
            // if we've got no time left, but we do have players left, pass it on
            guard status.otherPeople > 0 else { continue }
            deque.append(.init(flowReleased: status.flowReleased, current: "AA", opened: status.opened, otherPeople: status.otherPeople - 1, time: totalTime))
        }

        if status.opened == allFlowingValves {
            continue
        }

        if seen.contains(status) {
            continue
        }

        seen.insert(status)
        let currentValve = valves[status.current]!

        // if we have not visited this valve, and it will help to open it, lets open it
        if currentValve.flowRate > 0 && !status.opened.contains(currentValve.name){
            deque.append(State(flowReleased: status.flowReleased + ((status.time - 1) * (currentValve.flowRate)), current: status.current,
                               opened: status.opened.union([status.current]), otherPeople: status.otherPeople, time: status.time - 1))
        }

        // travel to each neighbor
        if status.time >= 1 {
            for neighbor in currentValve.connectedValveNames {
                deque.append(.init(flowReleased: status.flowReleased, current: neighbor, opened: status.opened, otherPeople: status.otherPeople, time: status.time - 1))
            }
        }
    }

    return best
}

//// MARK: - Part 1
func maximumFlowReleasedbySelf(from input: String) throws -> Int {
    let valves = try valvesParser.parse(input)
    let maxFlow = maximumFlowReleased(using: Dictionary(uniqueKeysWithValues: valves.map { ($0.name, $0) }), inTotalTime: 30, withOtherPeople: 0)
    return maxFlow
}

try measure(part: .one) {
    print("Solution: \(try maximumFlowReleasedbySelf(from: .testInput))")
}

// MARK: - Part 2
// Warning: It takes a really long time. Could/should/definitely be optimized.
func maximumFlowReleasedWithElephant(from input: String) throws -> Int {
    let valves = try valvesParser.parse(input)
    let maxFlow = maximumFlowReleased(using: Dictionary(uniqueKeysWithValues: valves.map { ($0.name, $0) }), inTotalTime: 26, withOtherPeople: 1)
    return maxFlow
}

try measure(part: .two) {
    print("Solution: \(try maximumFlowReleasedWithElephant(from: .input))")
}
