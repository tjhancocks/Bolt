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
        case bool(Bool, location: Mark)

        // Code Block, Groups
        case module([Expression], location: Mark)
        case block([Expression], location: Mark)
        case group([Expression], location: Mark)

        // Definitions
        case definition(declaration: Expression, body: Expression)

        // Functions
        case functionDeclaration(name: String, returnType: Expression, parameters: [Expression], location: Mark)
        case parameterDeclaration(name: String, type: Expression, location: Mark)

        // Variables
        case constantDeclaration(name: String, type: Expression, location: Mark)

        // Types
        case type(Type, location: Mark)

        // Identifiers
        case identifier(String, location: Mark)
        case boundIdentifier(Expression, location: Mark)

        // Expressions
        case call(identifier: Expression, arguments: [Expression], location: Mark)
        case voidReturn(location: Mark)
        case `return`(Expression, location: Mark)

        // Directives
        case linkerFlag(flag: String, location: Mark)
    }
}

// MARK: - Expression Location

extension AbstractSyntaxTree.Expression {
    var location: Mark {
        switch self {
        case let .string(_, location): return location
        case let .integer(_, location): return location
        case let .bool(_, location): return location
        case let .module(_, location): return location
        case let .block(_, location): return location
        case let .group(_, location): return location
        case let .call(_, _, location): return location
        case let .definition(declaration, _): return declaration.location
        case let .functionDeclaration(_, _, _, location): return location
        case let .parameterDeclaration(_, _, location): return location
        case let .constantDeclaration(_, _, location): return location
        case let .type(_, location): return location
        case let .identifier(_, location): return location
        case let .boundIdentifier(_, location): return location
        case let .voidReturn(location): return location
        case let .return(_, location): return location
        case let .linkerFlag(_, location): return location
        }
    }
}

// MARK: - Expression Type

extension AbstractSyntaxTree.Expression {
    var type: Type {
        switch self {
        case .string: return .string
        case .integer: return .int
        case .bool: return .bool
        case let .type(type, _): return type
        case let .call(identifier, _, _): return identifier.type
        case let .block(body, _): return body.last?.type ?? .none
        case let .group(body, _): return body.last?.type ?? .none
        case let .boundIdentifier(.functionDeclaration(_, returnType, _, _), _): return returnType.type
        case let .boundIdentifier(.constantDeclaration(_, type, _), _): return type.type
        case let .boundIdentifier(.parameterDeclaration(_, type, _), _): return type.type
        case let .return(expr, _): return expr.type
        case let .parameterDeclaration(_, type, _): return type.type

            // If an expression is unhandled, treat it as none.
            // Not all expressions have a type.
        default: return .none
        }
    }
}
