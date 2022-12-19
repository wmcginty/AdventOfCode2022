//
//  Measure.swift
//  
//
//  Created by Will McGinty on 12/19/22.
//

import Foundation

public enum Part {
    case one, two

    var title: String {
        switch self {
        case .one: return "Part 1"
        case .two: return "Part 2"
        }
    }
}

public func measure(part: Part, _ closure: @escaping () throws -> Void) rethrows {
    let start = Date()

    print(part.title)
    try closure()
    print("Elapsed: \(Date().timeIntervalSince(start))")
    print()
}
