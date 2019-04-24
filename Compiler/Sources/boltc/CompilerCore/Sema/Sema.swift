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

class Sema {
    private(set) var ast: AbstractSyntaxTree
    private(set) var symbolTable: SymbolTable

    init(ast: AbstractSyntaxTree) {
        self.ast = ast
        self.symbolTable = .init()
    }
}

extension Sema {
    func performAnalysis() throws {
        ast.update(expressions: try analyse(expressions: ast.expressions))
    }

    func analyse(expressions: [AbstractSyntaxTree.Expression]) throws -> [AbstractSyntaxTree.Expression] {
        var resultExpressions: [AbstractSyntaxTree.Expression] = []
        for expr in expressions {
            resultExpressions.append(contentsOf: try analyse(expression: expr))
        }
        return resultExpressions
    }

    func analyse(expression: AbstractSyntaxTree.Expression) throws -> [AbstractSyntaxTree.Expression] {
        switch expression {
        case let .block(expressions, location):
            return [.block(try analyse(expressions: expressions), location: location)]

        case .functionDeclaration, .definition(.functionDeclaration, _):
            return try FunctionSema.performSemanticAnalysis(on: expression, for: self)

        case .parameterDeclaration:
            return try ParameterSema.performSemanticAnalysis(on: expression, for: self)

        default:
            // Simply return unhandled cases as we're not performing any semantic
            // analysis of them yet (if needed at all).
            return [expression]
        }
    }
}

protocol SemaProtocol {
    static func performSemanticAnalysis(on expr: AbstractSyntaxTree.Expression, for sema: Sema) throws -> [AbstractSyntaxTree.Expression]
}
