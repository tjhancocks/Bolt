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

    private(set) var modules: [AbstractSyntaxTree.ModuleNode] = []
    private(set) var visitStack: [AbstractSyntaxTree.Node] = []
    private(set) var symbolTable: SymbolTable = .init()

    var visitNode: AbstractSyntaxTree.Node {
        guard let node = visitStack.last else {
            fatalError("AST visit stack is corrupted.")
        }
        return node
    }

    init(mainModuleName moduleName: String) {
        let initialModule = ModuleNode(named: moduleName, owner: self)
        self.modules.append(initialModule)
        self.visitStack.append(initialModule)
    }

    func traverse(_ body: (AbstractSyntaxTree.Node) throws -> [AbstractSyntaxTree.Node]) rethrows {
        try modules.forEach {
            _ = try $0.traverse(body)
        }
    }

    func visit(_ node: AbstractSyntaxTree.Node) {
        visitStack.append(node)
    }

    func leave() throws -> AbstractSyntaxTree.Node {
        guard visitStack.count == 1, let node = visitStack.popLast() else {
            throw Error.attemptedToLeaveMainModule
        }
        return node
    }

    func add(_ node: AbstractSyntaxTree.Node) {
        if let node = node as? AbstractSyntaxTree.ModuleNode {
            add(modules: [node], symbols: [])
        } else {
            visitNode.add(node)
        }
    }

    func add(modules: [AbstractSyntaxTree.ModuleNode], symbols: [SymbolTable.Symbol]) {
        symbolTable.add(rootSymbols: symbols)
        
        modules.enumerated().forEach { index, module in
            guard self.modules.contains(where: { $0.name == module.name }) == false else {
                // Module already included. Skip it.
                return
            }
            self.modules.insert(module, at: 0 + index)
        }
    }
}

extension AbstractSyntaxTree: CustomStringConvertible {
    var description: String {
        let modules = self.modules.map({ $0.description }).joined(separator: ", ")
        return "AST containing modules '\(modules)'"
    }
}

// MARK: - Node Foundation

extension AbstractSyntaxTree {
    class Node: CustomStringConvertible {
        private(set) var owner: AbstractSyntaxTree?
        private(set) var parent: AbstractSyntaxTree.Node?
        private(set) var children: [AbstractSyntaxTree.Node] = []

        var valueType: Type {
            return .none
        }

        init(owner: AbstractSyntaxTree? = nil) {
            self.owner = owner
        }

        func add(_ node: AbstractSyntaxTree.Node) {
            node.owner = owner
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

        init(named name: String, owner: AbstractSyntaxTree) {
            self.name = name
            super.init(owner: owner)
        }

        override var description: String {
            let childrenDescription = children.map({ "\t\($0.description)" }).joined(separator: "\n")
            return "Module \(name)\n\(childrenDescription)"
        }
    }
}

// MARK: - Errors

extension AbstractSyntaxTree {
    enum Error: Swift.Error {
        case attemptedToLeaveMainModule
    }
}
