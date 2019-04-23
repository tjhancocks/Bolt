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

    private(set) var rootSymbols: [Symbol] {
        get {
            guard let scope = symbolScopes.first else {
                fatalError("Missing symbol scope - aborting as compiler is in bad state")
            }
            return scope
        }
        set {
            symbolScopes.removeFirst()
            symbolScopes.insert(newValue, at: 0)
        }
    }

    func enterScope() {
        // We need to clone the existing scope.
        symbolScopes.append(currentScope)
    }

    func leaveScope(file: StaticString = #file, line: UInt = #line) {
        guard symbolScopes.isEmpty == false else {
            fatalError("The compiler attempted to leave the main scope of the program. This will most likely be due to an imbalance in the enter/leave calls in the SymbolTable around \(file):\(line)")
        }
        _ = symbolScopes.popLast()
    }

    func find(symbolNamed name: String) -> AbstractSyntaxTree.Expression? {
        return currentScope.first(where: { $0.name == name })?.expression
    }

    func defineSymbol(name: String, expression: AbstractSyntaxTree.Expression, location: Mark) throws {
        if let original = find(symbolNamed: name) {
            throw Error.parserError(location: location, reason: .redefinition(of: original, with: expression))
        }

        // At this point we are allowed to create.
        currentScope.append(Symbol(name: name, fullName: name, expression: expression))
    }

    func add(rootSymbols: [SymbolTable.Symbol]) {
        self.rootSymbols.insert(contentsOf: rootSymbols, at: 0)
    }

}

extension SymbolTable {
    class Symbol {
        let name: String
        let fullName: String
        let expression: AbstractSyntaxTree.Expression

        init(name: String, fullName: String, expression: AbstractSyntaxTree.Expression) {
            self.name = name
            self.fullName = fullName
            self.expression = expression
        }
    }
}
