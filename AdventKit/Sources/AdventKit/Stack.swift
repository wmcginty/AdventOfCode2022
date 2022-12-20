//
//  Stack.swift
//  
//
//  Created by Will McGinty on 12/20/22.
//

import Foundation

// MARK: - Stack
public struct Stack<T> {

    // MARK: - Properties
    private var contents: [T]

    // MARK: - Initializer
    public init() {
        self.contents = []
    }

    // MARK: - Interface
    public var isEmpty: Bool { return contents.isEmpty }
    public var top: T? { return contents.first }

    public mutating func push(_ element: T) {
        contents.insert(element, at: 0)
    }

    public mutating func pop() -> T {
        return contents.removeFirst()
    }
}
