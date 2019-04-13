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

class SymbolTable {

    private var symbolScopes: [[Symbol]] = [[]]

    private var currentScope: [Symbol] {
        get {
            guard let scope = symbolScopes.last else {
                fatalError("Missing symbol scope - aborting as compiler is in bad state")
            }
            return scope
        }
        set {
            symbolScopes.removeLast()
            symbolScopes.append(newValue)
        }
    }

    func enterScope() {
        // We need to clone the existing scope.
        symbolScopes.append(currentScope)
        print("Entered scope")
    }

    func leaveScope() {
        _ = symbolScopes.popLast()
        print("Left scope")
    }

    func find(symbolNamed name: String) -> AbstractSyntaxTree.Node? {
        return currentScope.first(where: { $0.name == name })?.node
    }

    func defineSymbol(name: String, node: AbstractSyntaxTree.Node) {
        if let _ = find(symbolNamed: name) {
            fatalError("Attempted to redefine symbol: \(node)")
        }

        // At this point we are allowed to create.
        print("+\(name)")
        currentScope.append(Symbol(name: name, fullName: name, node: node))
    }

}

extension SymbolTable {
    class Symbol {
        let name: String
        let fullName: String
        let node: AbstractSyntaxTree.Node

        init(name: String, fullName: String, node: AbstractSyntaxTree.Node) {
            self.name = name
            self.fullName = fullName
            self.node = node
        }
    }
}
