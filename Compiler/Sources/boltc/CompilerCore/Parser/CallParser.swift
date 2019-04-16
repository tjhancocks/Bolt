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

struct CallParser: ParserHelperProtocol {
    func test(for scanner: Scanner<[Token]>) -> Bool {
        if case .identifier? = scanner.peek(), case .symbol(.leftParen, _)? = scanner.peek(ahead: 1) {
            return true
        } else {
            return false
        }
    }

    func parse(from scanner: Scanner<[Token]>, ast: AbstractSyntaxTree) throws -> AbstractSyntaxTree.Node {

        // Target function
        let idParser = IdentifierParser()
        guard idParser.test(for: scanner), let id = try idParser.parse(from: scanner, ast: ast) as? AbstractSyntaxTree.IdentifierNode else {
            fatalError("Begun parsing what was expected to be a function call, but didn't find a function call. This is may mean the parser is out of sync with itself.")
        }

        // Argument list
        try scanner.consume(expected: .symbol(symbol: .leftParen, mark: .unknown))
        var arguments: [AbstractSyntaxTree.Node] = []

        let parsers = Parser.scopedParsers
        nextArgument: while scanner.available {
            if case .symbol(.rightParen, _)? = scanner.peek() {
                break
            }

            for parser in parsers {
                if parser.test(for: scanner) {
                    arguments.append(try parser.parse(from: scanner, ast: ast))

                    if case .symbol(.comma, _)? = scanner.peek() {
                        scanner.advance()
                        continue nextArgument
                    } else {
                        break nextArgument
                    }
                }
            }

            // Reaching this point is an indication of something not being handled.
            throw Error.parserError(location: scanner.location,
                                    reason: .unexpectedTokenEncountered(token: scanner.token))
        }

        try scanner.consume(expected: .symbol(symbol: .rightParen, mark: .unknown))

        return AbstractSyntaxTree.CallNode(function: id, arguments: arguments, mark: id.mark)
    }
}
