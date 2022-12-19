//
//  main.swift
//  Day16
//
//  Created by Will McGinty on 12/19/22.
//

import Foundation
import Parsing

let testInput = """
Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
"""

struct Valve: Equatable {
    let name: String
    let flowRate: Int
    let connectedValveNames: [String]
}

let inputParser = Parse {
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


class Graph<T> {

    public class Vertex {

        var value: T
        var neighbors: [Edge] = []

        init(value: T) {
            self.value = value
        }

        func addNeighbor(_ vertex: Vertex, weight: Int) {
            neighbors.append(.init(neighbor: vertex, weight: weight))
        }
    }

    public class Edge {
        var neighbor: Vertex
        var weight: Int

        init(neighbor: Vertex, weight: Int) {
            self.neighbor = neighbor
            self.weight = weight
        }

    }

    private(set) var canvas: [Vertex]

    init() {
        canvas = []
    }

    convenience init(valves: [T]) where T == Valve {
        self.init()

        for valve in valves {
            let vertex = Vertex(value: valve)
            addVertex(vertex)

            let connectedValves = valve.connectedValveNames.compactMap { name in valves.first(where: { $0.name == name }) }
            for neighboringValve in connectedValves {
                let neighbor = Vertex(value: neighboringValve)
                addEdge(from: vertex, to: neighbor, weight: 1)
            }
        }
    }

    func addVertex(_ vertex: Vertex) {
        canvas.append(vertex)
    }

    func addEdge(from vertex: Vertex, to other: Vertex, weight: Int) {
        vertex.addNeighbor(other, weight: weight)
    }
}

// MARK: - Part 1
func part1(from input: String) throws -> Void {
    let valves = try Many { inputParser } separator: { "\n" }.parse(input)
    var graph = Graph<Valve>(valves: valves)
}

try part1(from: testInput)
