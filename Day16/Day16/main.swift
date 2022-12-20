//
//  main.swift
//  Day16
//
//  Created by Will McGinty on 12/19/22.
//

import Foundation
import AdventKit
import Parsing

struct Valve: Hashable {
    let name: String
    let flowRate: Int
    let connectedValveNames: [String]
}

struct IndexedValve: Hashable {
    let index: Int
    let valve: Valve
    
    var name: String { valve.name }
    var flowRate: Int { valve.flowRate }
    var connectedValveNames: [String] { valve.connectedValveNames }
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
}.map { Valve(name: String($0), flowRate: $1, connectedValveNames: $2.map(String.init)) }

let valvesParser = Many { valveParser } separator: { "\n" }

class Solver {
    
    struct Key: Hashable {
        let position: Int
        let opened: Set<Int>
        let timeRemaining: Int
        let otherPlayers: Int
    }

    let valveDict: [String: IndexedValve]
    private var cache: [Key: Int] = [:]
    
    init(valveDict: [String: IndexedValve]) {
        self.valveDict = valveDict
    }

    /* What is the maximum score I can achieve when I have am [valveName], after opening [opened] vales,
     with [timeRemaining] time remainining our of [maximumTime], with [otherPlayers] left to run. */
    func maxFlowReleasable(at valveName: String, afterOpening opened: Set<IndexedValve>,
                           timeRemaining: Int, maximumTime: Int, otherPlayers: Int) -> Int {
        if timeRemaining == 0 {
            // If we have no time left, but other players left -> start running them
            return otherPlayers > 0 ? maxFlowReleasable(at: "AA", afterOpening: opened,
                                                        timeRemaining: maximumTime, maximumTime: maximumTime, otherPlayers: otherPlayers - 1) : 0
        }
        
        let valve = valveDict[valveName]!
        let key = Key(position: valve.index, opened: Set(opened.map(\.index)), timeRemaining: timeRemaining, otherPlayers: otherPlayers)
        if let cached = cache[key] {
            // If we've previously seen this position, we already know the max score achievable from here
            return cached
        }
        
        var answer: Int = 0
        
        //if we haven't opened this valve, and we should, open it
        if !opened.contains(valve) && valve.flowRate > 0 {
            let futureFlow = ((timeRemaining - 1) * valve.flowRate) + maxFlowReleasable(at: valve.name, afterOpening: opened.union([valve]),
                                                                                        timeRemaining: timeRemaining - 1, maximumTime: maximumTime, otherPlayers: otherPlayers)
            answer = max(answer, futureFlow)
        }
        
        // traverse the neighbors
        for neighbor in valve.connectedValveNames {
            answer = max(answer, maxFlowReleasable(at: neighbor, afterOpening: opened, timeRemaining: timeRemaining - 1, maximumTime: maximumTime, otherPlayers: otherPlayers))
        }
        
        cache[key] = answer
        return answer
    }
}

let valves = try valvesParser.parse(String.input).enumerated().map { IndexedValve(index: $0.offset, valve: $0.element) }
let solver = Solver(valveDict: Dictionary(uniqueKeysWithValues: valves.map { ($0.name, $0) }))

// MARK: - Part 1
measure(part: .one) {
    print("Solution: \(solver.maxFlowReleasable(at: "AA", afterOpening: [], timeRemaining: 30, maximumTime: 30, otherPlayers: 0))")
}

// MARK: - Part 2
measure(part: .two) {
    print("Solution: \(solver.maxFlowReleasable(at: "AA", afterOpening: [], timeRemaining: 26, maximumTime: 26, otherPlayers: 1))")
}
