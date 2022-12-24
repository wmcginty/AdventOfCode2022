//
//  File.swift
//  
//
//  Created by Will McGinty on 12/24/22.
//

import Foundation

public extension Int {

    func gcd(with other: Int) -> Int {
        let r = self % other
        if r != 0 {
            return other.gcd(with: r)
        } else {
            return other
        }
    }

    func lcm(with other: Int) -> Int {
        return self / gcd(with: other) * other
    }
}
