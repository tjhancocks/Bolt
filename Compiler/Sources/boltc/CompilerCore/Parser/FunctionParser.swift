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

struct FunctionParser: ParserHelperProtocol {
    func test(for scanner: Scanner<[Token]>) -> Bool {
        if case .keyword(.func, _)? = scanner.peek(), case .symbol(.leftAngle, _)? = scanner.peek(ahead: 1) {
            return true
        } else {
            return false
        }
    }

    func parse(from scanner: Scanner<[Token]>, ast: AbstractSyntaxTree) throws -> AbstractSyntaxTree.Node {
        // Function declaration prologue: func<
        try scanner.consume(expected:
            .keyword(keyword: .func, mark: .unknown),
            .symbol(symbol: .leftAngle, mark: .unknown)
        )

        // Function return type
        let returnType = try TypeParser.parse(from: scanner, ast: ast)

        // Post return type: >
        try scanner.consume(expected:
            .symbol(symbol: .rightAngle, mark: .unknown)
        )

        // Function name
        let functionNameToken = scanner.advance()
        guard case let .identifier(name, mark) = functionNameToken else {
            throw Error.parserError(location: scanner.location,
                                    reason: .unexpectedTokenEncountered(token: functionNameToken))
        }

        // Parameters
        try scanner.consume(expected:.symbol(symbol: .leftParen, mark: .unknown))
        var parameters: [AbstractSyntaxTree.ParameterNode] = []
        while scanner.available {
            if case .symbol(.rightParen, _)? = scanner.peek() {
                break
            }

            parameters.append(try ParameterParser.parse(from: scanner, ast: ast))

            if case .symbol(.comma, _)? = scanner.peek() {
                scanner.advance()
            } else {
                break
            }
        }
        try scanner.consume(expected: .symbol(symbol: .rightParen, mark: .unknown))

        // Build the declaration
        let declaration = AbstractSyntaxTree.FunctionNode(name: name, returnType: returnType, parameters: parameters, mark: mark)
        ast.symbolTable.defineSymbol(name: name, node: declaration)

        // Check if there is a code body attached? If so then add it.
        let codeBlockParser = CodeBlockParser()
        if codeBlockParser.test(for: scanner) {
            ast.symbolTable.enterScope()

            parameters.forEach {
                ast.symbolTable.defineSymbol(name: $0.name, node: $0)
            }

            declaration.add(try codeBlockParser.parse(from: scanner, ast: ast))
            ast.symbolTable.leaveScope()
        }

        // Return the function node.
        return declaration
    }
}
