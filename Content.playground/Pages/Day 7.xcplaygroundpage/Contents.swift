//: [Previous](@previous)

import Foundation
import Parsing

let inputURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let input = try String(String(contentsOf: inputURL!, encoding: String.Encoding.utf8).dropLast(1)) // Xcode forces an empty newline at the end of the file :(

enum Input {
    case command(Command)
    case contents(Contents)
}

enum Command {
    case changeDirectory(String)
    case listContents
}

enum Contents: Equatable {
    case directory(String)
    case file(String, UInt)
}

public class TreeNode<T> {
    public var value: T
    public var children: [TreeNode] = []
    public weak var parent: TreeNode?

    public init(_ value: T) {
        self.value = value
    }

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

let changeDirectoryParse = Parse {
    "cd "
    Prefix(while: { $0 != "\n" })
}.map { Command.changeDirectory(String($0)) }

let commandParse = Parse {
    "$ "
    OneOf {
        changeDirectoryParse
        "ls".map { Command.listContents }
    }
}

let directoryContentParse = Parse {
    "dir "
    Prefix(while: { $0 != "\n" })
}.map { Contents.directory(String($0)) }

let fileContentParse = Parse {
    UInt.parser()
    " "
    Prefix(while: { $0 != "\n" })
}.map { Contents.file(String($1), $0) }

let contentsParse = Parse {
    OneOf {
        directoryContentParse
        fileContentParse
    }
}

let inputParse = Parse {
    OneOf {
        commandParse.map { Input.command($0) }
        contentsParse.map { Input.contents($0) }
    }
}

let terminalInput = try Many { inputParse } separator: { "\n" }.parse(input)
let tree = TreeNode(terminalInput: terminalInput)

extension TreeNode where T == Contents {

    convenience init(terminalInput: [Input]) {
        self.init(.directory("/"))

        var currentNode: TreeNode<Contents> = self
        for input in terminalInput.dropFirst() {
            switch input {
            case .contents(let contents): currentNode.add(contents)
            case .command(let command):
                switch command {
                case .listContents: continue
                case .changeDirectory(let directory):
                    switch directory {
                    case "..":
                        guard let parent = currentNode.parent else { return }
                        currentNode = parent

                    default:
                        guard let matchingChild = currentNode.children.first(where: { $0.value == .directory(directory) }) else { return }
                        currentNode = matchingChild
                    }
                }
            }
        }
    }

    var fileSize: UInt {
        switch value {
        case .file(_, let size): return size
        case .directory(_): return children.map(\.fileSize).reduce(0,+)
        }
    }
}

// MARK: Part 1
func totalSizeOfAllDirectories(in tree: TreeNode<Contents>, over limit: UInt) -> UInt {
    var directories: [UInt] = []
    tree.depthFirstTraversal { treeNode in
        switch treeNode.value {
        case .directory: directories.append(treeNode.fileSize)
        default: break
        }
    }

    return directories.filter { $0 <= 100000 }.reduce(0, +)
}

print("Part 1: \(totalSizeOfAllDirectories(in: tree, over: 100_000))")

// MARK: - Part 2
func smallestDirectorySizeToDelete(in tree: TreeNode<Contents>, toFreeAtLeast requiredSize: UInt, withTotalSize totalSize: UInt) -> UInt {
    let occupiedSize = tree.fileSize
    let freeSize = totalSize - occupiedSize
    let requiredSizeToFree = requiredSize - freeSize

    var directory: (TreeNode<Contents>, UInt)? = nil
    tree.depthFirstTraversal { treeNode in
        switch treeNode.value {
        case .directory:
            let fileSize = treeNode.fileSize
            if fileSize >= requiredSizeToFree {
                if let existingSmallest = directory {
                    if fileSize < existingSmallest.1 {
                        directory = (treeNode, fileSize)
                    }
                } else {
                    directory = (treeNode, fileSize)
                }
            }
        default: break
        }
    }

    return directory?.1 ?? 0
}

print("Part 2: \(smallestDirectorySizeToDelete(in: tree, toFreeAtLeast: 30_000_000, withTotalSize: 700_000_00))")

//: [Next](@next)
