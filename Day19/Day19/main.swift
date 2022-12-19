//
//  main.swift
//  Day19
//
//  Created by Will McGinty on 12/19/22.
//

import Foundation
import AdventKit
import Collections
import Parsing

struct Blueprint {
    let id: Int
    let oreRobotOreCost: Int
    let clayRobotOreCost: Int
    let obsidianRobotOreCost: Int
    let obsidianRobotClayCost: Int
    let geodeRobotOreCost: Int
    let geodeRobotObsidianCost: Int

    var maxOreSpendInOneTurn: Int {
        return max(oreRobotOreCost, clayRobotOreCost, obsidianRobotOreCost, geodeRobotOreCost)
    }

    var maxClaySpendInOneTurn: Int {
        return obsidianRobotClayCost
    }

    var maxObsidianSpendInOneTurn: Int {
        return geodeRobotObsidianCost
    }
}

let blueprintParser = Parse {
    "Blueprint "
    Int.parser()
    ": Each ore robot costs "
    Int.parser()
    " ore. Each clay robot costs "
    Int.parser()
    " ore. Each obsidian robot costs "
    Int.parser()
    " ore and "
    Int.parser()
    " clay. Each geode robot costs "
    Int.parser()
    " ore and "
    Int.parser()
    " obsidian."
}.map(Blueprint.init)

let blueprintsParser = Many { blueprintParser } separator: { "\n" }

struct State: Hashable {
    var ore: Int
    var clay: Int
    var obsidian: Int
    var geodes: Int

    var oreRobots: Int
    var clayRobots: Int
    var obsidianRobots: Int
    var geodeRobots: Int

    var time: Int
}

func maxGeodes(from blueprint: Blueprint, inTotalTime totalTime: Int) -> Int {
    var best = 0
    let start = State(ore: 0, clay: 0, obsidian: 0, geodes: 0, oreRobots: 1, clayRobots: 0, obsidianRobots: 0, geodeRobots: 0, time: totalTime)
    var deque = Deque([start])
    var seen = Set<State>()

    while var status = deque.popFirst() {
        best = max(best, status.geodes)

        if status.time == 0 {
            continue
        }

        let maxOreSpendLeft = (status.time * blueprint.maxOreSpendInOneTurn) - (status.oreRobots * (status.time - 1))
        if status.ore > maxOreSpendLeft {
            status.ore = maxOreSpendLeft
        }

        let maxClaySpendLeft = (status.time * blueprint.maxClaySpendInOneTurn) - (status.clayRobots * (status.time - 1))
        if status.clay > maxClaySpendLeft {
            status.clay = maxClaySpendLeft
        }

        let maxObsidianSpendLeft = (status.time * blueprint.maxObsidianSpendInOneTurn) - (status.obsidianRobots * (status.time - 1))
        if status.obsidian > maxObsidianSpendLeft {
            status.obsidian = maxObsidianSpendLeft
        }

        if seen.contains(status) {
            continue
        }
        seen.insert(status)

        //don't buy a robot
        deque.append(.init(ore: status.ore + status.oreRobots, clay: status.clay + status.clayRobots,
                           obsidian: status.obsidian + status.obsidianRobots, geodes: status.geodes + status.geodeRobots,
                           oreRobots: status.oreRobots, clayRobots: status.clayRobots, obsidianRobots: status.obsidianRobots, geodeRobots: status.geodeRobots, time: status.time - 1))

        if status.ore >= blueprint.geodeRobotOreCost && status.obsidian >= blueprint.geodeRobotObsidianCost {
            // or buy a geode robot
            deque.append(.init(ore: status.ore + status.oreRobots - blueprint.geodeRobotOreCost, clay: status.clay + status.clayRobots,
                               obsidian: status.obsidian + status.obsidianRobots - blueprint.geodeRobotObsidianCost, geodes: status.geodes + status.geodeRobots,
                               oreRobots: status.oreRobots, clayRobots: status.clayRobots, obsidianRobots: status.obsidianRobots, geodeRobots: status.geodeRobots + 1, time: status.time - 1))
        } else {
            if status.ore >= blueprint.oreRobotOreCost && status.oreRobots < blueprint.maxOreSpendInOneTurn {
                // or buy an ore robot
                deque.append(.init(ore: status.ore + status.oreRobots - blueprint.oreRobotOreCost, clay: status.clay + status.clayRobots,
                                   obsidian: status.obsidian + status.obsidianRobots, geodes: status.geodes + status.geodeRobots,
                                   oreRobots: status.oreRobots + 1, clayRobots: status.clayRobots, obsidianRobots: status.obsidianRobots, geodeRobots: status.geodeRobots, time: status.time - 1))
            }

            if status.ore >= blueprint.clayRobotOreCost && status.clayRobots < blueprint.maxClaySpendInOneTurn {
                // or buy a clay robot
                deque.append(.init(ore: status.ore + status.oreRobots - blueprint.clayRobotOreCost, clay: status.clay + status.clayRobots ,
                                   obsidian: status.obsidian + status.obsidianRobots, geodes: status.geodes + status.geodeRobots,
                                   oreRobots: status.oreRobots, clayRobots: status.clayRobots + 1, obsidianRobots: status.obsidianRobots, geodeRobots: status.geodeRobots, time: status.time - 1))
            }

            if status.ore >= blueprint.obsidianRobotOreCost && status.clay >= blueprint.obsidianRobotClayCost && status.obsidianRobots < blueprint.maxObsidianSpendInOneTurn {
                //or buy an obsidian robot
                deque.append(.init(ore: status.ore + status.oreRobots - blueprint.obsidianRobotOreCost, clay: status.clay + status.clayRobots - blueprint.obsidianRobotClayCost,
                                   obsidian: status.obsidian + status.obsidianRobots, geodes: status.geodes + status.geodeRobots,
                                   oreRobots: status.oreRobots, clayRobots: status.clayRobots, obsidianRobots: status.obsidianRobots + 1, geodeRobots: status.geodeRobots, time: status.time - 1))
            }
        }
    }

    return best
}

// MARK: - Part 1
func qualityLevelOfBlueprints(from input: String) throws -> Int {
    let blueprints = try blueprintsParser.parse(input)
    return blueprints.reduce(0) { partialResult, blueprint in
        let geodes = maxGeodes(from: blueprint, inTotalTime: 24)
        return partialResult + (geodes * blueprint.id)
    }
}

try AdventKit.measure(part: .one) {
    print("Solution: \(try qualityLevelOfBlueprints(from: .input))")
}

// MARK: - Part 2
func productOfGeodeCounts(from input: String) throws -> Int {
    let blueprints = try blueprintsParser.parse(input).prefix(3)
    return blueprints.reduce(1) { partialResult, blueprint in
        let geodes = maxGeodes(from: blueprint, inTotalTime: 32)
        return partialResult * geodes
    }
}

try AdventKit.measure(part: .two) {
    print("Solution: \(try productOfGeodeCounts(from: .input))")
}
