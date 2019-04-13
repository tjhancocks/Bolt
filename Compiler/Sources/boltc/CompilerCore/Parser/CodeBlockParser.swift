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

struct CodeBlockParser: ParserHelperProtocol {

    func test(for scanner: Scanner<[Token]>) -> Bool {
        if case .symbol(.leftBrace, _)? = scanner.peek() {
            return true
        } else {
            return false
        }
    }

    func parse(from scanner: Scanner<[Token]>, ast: AbstractSyntaxTree) throws -> AbstractSyntaxTree.Node {
        try scanner.consume(expected: .symbol(symbol: .leftBrace, mark: .unknown))
        ast.symbolTable.enterScope()

        var expressions: [AbstractSyntaxTree.Node] = []
        let parsers = Parser.scopedParsers

        nextExpression: while scanner.available {
            if case .symbol(.rightBrace, _)? = scanner.peek() {
                break
            }

            for parser in parsers {
                if parser.test(for: scanner) {
                    expressions.append(try parser.parse(from: scanner, ast: ast))
                    continue nextExpression
                }
            }

            // Reaching this point is an indication of something not being handled.
            throw Error.parserError(location: scanner.location,
                                    reason: .unexpectedTokenEncountered(token: scanner.token))
        }

        ast.symbolTable.leaveScope()
        try scanner.consume(expected: .symbol(symbol: .rightBrace, mark: .unknown))

        return AbstractSyntaxTree.CodeBlockNode(children: expressions, mark: .unknown)
    }
}
