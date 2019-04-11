// Copyright (c) 2019 Tom Hancocks
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

class AbstractSyntaxTree {
    private(set) var root: Node

    init(moduleName: String) {
        self.root = ModuleNode(named: moduleName)
    }

    func traverse(_ body: (AbstractSyntaxTree.Node) throws -> [AbstractSyntaxTree.Node]) rethrows {
        _ = try root.traverse(body)
    }
}

extension AbstractSyntaxTree: CustomStringConvertible {
    var description: String {
        return "AST of '\(root)'"
    }
}

// MARK: - Node Foundation

extension AbstractSyntaxTree {
    class Node: CustomStringConvertible {
        private(set) var parent: AbstractSyntaxTree.Node?
        private(set) var children: [AbstractSyntaxTree.Node] = []

        func add(_ node: AbstractSyntaxTree.Node) {
            children.append(node)
        }

        var description: String {
            return "AST Node"
        }
    }
}

extension AbstractSyntaxTree.Node {
    func traverse(_ body: (AbstractSyntaxTree.Node) throws -> [AbstractSyntaxTree.Node]) rethrows {
        _ = try body(self)

        var newChildren: [AbstractSyntaxTree.Node] = []
        try children.forEach { node in
            newChildren.append(contentsOf: try body(node))
        }
        children = newChildren
    }
}


// MARK: - Module Root

extension AbstractSyntaxTree {
    class ModuleNode: Node {
        private(set) var name: String

        init(named name: String) {
            self.name = name
        }

        override var description: String {
            return "Module \(name)"
        }
    }
}

