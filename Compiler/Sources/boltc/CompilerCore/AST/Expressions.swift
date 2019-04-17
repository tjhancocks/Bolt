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

extension AbstractSyntaxTree {
    indirect enum Expression {
        // Literals
        case string(String, location: Mark)
        case integer(Int, location: Mark)

        // Code Block, Groups
        case block([Expression], location: Mark)

        // Definitions
        case definition(declaration: Expression, body: Expression)

        // Functions
        case functionDeclaration(name: String, returnType: Expression, parameters: [Expression], location: Mark)
        case parameterDeclaration(name: String, type: Expression, location: Mark)

        // Variables
        case variableDeclaration(name: String, type: Expression, location: Mark)

        // Types
        case type(Type, location: Mark)

        // Identifiers
        case identifier(String, location: Mark)
        case function(String, location: Mark)
        case variable(String, location: Mark)
        case parameter(String, location: Mark)

        // Expressions
        case call(identifier: Expression, arguments: [Expression], location: Mark)
        case voidReturn(location: Mark)
        case `return`(Expression, location: Mark)
    }
}

// MARK: - Expression Location

extension AbstractSyntaxTree.Expression {
    var location: Mark {
        switch self {
        case let .string(_, location): return location
        case let .integer(_, location): return location
        case let .block(_, location): return location
        case let .call(_, _, location): return location
        case let .definition(declaration, _): return declaration.location
        case let .functionDeclaration(_, _, _, location): return location
        case let .parameterDeclaration(_, _, location): return location
        case let .variableDeclaration(_, _, location): return location
        case let .type(_, location): return location
        case let .identifier(_, location): return location
        case let .function(_, location): return location
        case let .variable(_, location): return location
        case let .parameter(_, location): return location
        case let .voidReturn(location): return location
        case let .return(_, location): return location
        }
    }
}
