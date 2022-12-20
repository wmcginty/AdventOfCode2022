//
//  TreeNode.swift
//  
//
//  Created by Will McGinty on 12/20/22.
//

import Foundation

public class TreeNode<T> {

    // MARK: - Properties
    public var value: T
    public var children: [TreeNode] = []
    public weak var parent: TreeNode?

    // MARK: - Initializer
    public init(_ value: T) {
        self.value = value
    }

    // MARK: - Interface
    public func add(_ value: T) {
        let child = TreeNode(value)
        child.parent = self
        children.append(child)
    }

    public func depthFirstTraversal(visit: (TreeNode) -> Void) {
        visit(self)
        children.forEach {
            $0.depthFirstTraversal(visit: visit)
        }
    }
}
