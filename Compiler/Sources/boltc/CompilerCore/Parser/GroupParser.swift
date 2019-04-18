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

struct GroupParser: SubParserProtocol {

    static func test(scanner: Scanner<[Token]>) -> Bool {
        return scanner.test(expected:
            .symbol(symbol: .leftParen, mark: .unknown)
        )
    }

    static func parse(scanner: Scanner<[Token]>, owner parser: Parser) throws -> AbstractSyntaxTree.Expression {
        return try parse(scanner: scanner, owner: parser) { _, parser in
            return try parser.parseNextExpression()
        }
    }

    static func parse(
        scanner: Scanner<[Token]>,
        owner parser: Parser,
        parseFn: (Scanner<[Token]>, Parser) throws -> AbstractSyntaxTree.Expression
    ) throws -> AbstractSyntaxTree.Expression {
        let location = scanner.location
        var expressions: [AbstractSyntaxTree.Expression] = []

        // Assume that the '(' is present. The test should have been run first, or we've
        // been invoked from an area that expects it.
        scanner.advance()

        groupParser: while scanner.available {
            // If we hit a ')' then break out of the group.
            if scanner.test(expected: .symbol(symbol: .rightParen, mark: .unknown)) {
                break groupParser
            }
            expressions.append(try parseFn(scanner, parser))

            // If the next token is a ',' then we know to continue the list,
            // otherwise it must be a ')' to terminate the list.
            // Anything else is an error.
            if scanner.test(expected: .symbol(symbol: .comma, mark: .unknown)) {
                scanner.advance()
                continue groupParser
            }
            else if scanner.test(expected: .symbol(symbol: .rightParen, mark: .unknown)) {
                break groupParser
            }
            else {
                throw Error.parserError(location: scanner.location,
                                        reason: .unexpectedTokenEncountered(token: scanner.advance()))
            }
        }

        // Consume the closing ')'
        scanner.advance()

        return .group(expressions, location: location)
    }

}
