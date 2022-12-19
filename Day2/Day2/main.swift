//
//  main.swift
//  Day2
//
//  Created by Will McGinty on 12/19/22.
//

import Foundation

enum Play: Int {
    case rock = 1
    case paper = 2
    case scissors = 3

    init?(character: Character) {
        switch character {
        case "A", "X": self = .rock
        case "B", "Y": self = .paper
        case "C", "Z": self = .scissors
        default: return nil
        }
    }

    init(opponent: Play, desiredOutcome: Outcome) {
        switch (opponent, desiredOutcome) {
        case (.rock, .win): self = .paper
        case (.rock, .draw): self = .rock
        case (.rock, .loss): self = .scissors
        case (.paper, .win): self = .scissors
        case (.paper, .draw): self = .paper
        case (.paper, .loss): self = .rock
        case (.scissors, .win): self = .rock
        case (.scissors, .draw): self = .scissors
        case (.scissors, .loss): self = .paper
        }
    }
}

enum Outcome: Int {
    case win = 6
    case draw = 3
    case loss = 0

    init?(character: Character) {
        switch character {
        case "X": self = .loss
        case "Y": self = .draw
        case "Z": self = .win
        default: return nil
        }
    }

    init(your: Play, opponents: Play) {
        switch (your, opponents) {
        case (.rock, .rock): self = .draw
        case (.rock, .paper): self = .loss
        case (.rock, .scissors): self = .win
        case (.paper, .rock): self = .win
        case (.paper, .paper): self = .draw
        case (.paper, .scissors): self = .loss
        case (.scissors, .rock): self = .loss
        case (.scissors, .paper): self = .win
        case (.scissors, .scissors): self = .draw
        }
    }
}

// Part 1
func totalScore(given input: String) -> Int {
    let outcomes: [(Play, Outcome)] = input.components(separatedBy: "\n").compactMap {
        guard let opponent = Play(character: $0[$0.startIndex]), let your = Play(character: $0[$0.index(before: $0.endIndex)]) else { return nil }
        return (your, Outcome(your: your, opponents: opponent))
    }

    return outcomes.map { $0.0.rawValue + $0.1.rawValue }.reduce(0, +)
}

print("Part 1: \(totalScore(given: .input))")


// Part 2
func totalScore2(given input: String) -> Int {
    let outcomes: [(Play, Outcome)] = input.components(separatedBy: "\n").compactMap {
        guard let opponent = Play(character: $0[$0.startIndex]), let desiredOutcome = Outcome(character: $0[$0.index(before: $0.endIndex)]) else { return nil }

        let your = Play(opponent: opponent, desiredOutcome: desiredOutcome)
        return (your, Outcome(your: your, opponents: opponent))
    }

    return outcomes.map { $0.0.rawValue + $0.1.rawValue }.reduce(0, +)
}

print("Part 2: \(totalScore2(given: .input))")

