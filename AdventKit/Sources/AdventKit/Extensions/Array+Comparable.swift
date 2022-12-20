//
//  Array+Comparable.swift
//  
//
//  Created by Will McGinty on 12/20/22.
//

import Foundation

extension Array: Comparable where Element: Comparable {

    public static func < (lhs: [Element], rhs: [Element]) -> Bool {
        for (leftElement, rightElement) in zip(lhs, rhs) {
            if leftElement < rightElement {
                return true
            } else if leftElement > rightElement {
                return false
            }
        }

        return lhs.count < rhs.count
    }
}
