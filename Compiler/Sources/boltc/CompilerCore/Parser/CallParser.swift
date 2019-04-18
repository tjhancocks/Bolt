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

struct CallParser: SubParserProtocol {

    static func test(scanner: Scanner<[Token]>) -> Bool {
        return scanner.test(weakIdentifier: true, expected:
            .identifier(text: "foo", mark: scanner.location),
            .symbol(symbol: .leftParen, mark: scanner.location)
        )
    }

    static func parse(scanner: Scanner<[Token]>, owner parser: Parser) throws -> AbstractSyntaxTree.Expression {
        guard case let .identifier(identifierName, location)? = scanner.peek() else {
            throw Error.parserError(location: scanner.location,
                                    reason: .expected(token: .identifier(text: "foo", mark: scanner.location)))
        }
        scanner.advance()

        guard GroupParser.test(scanner: scanner) else {
            throw Error.parserError(location: scanner.location,
                                    reason: .expected(token: .symbol(symbol: .leftParen, mark: scanner.location)))
        }
        guard case let .group(arguments, _) = try GroupParser.parse(scanner: scanner, owner: parser) else {
            fatalError("GroupParser returned an unexpected expression.")
        }

        return .call(identifier: .identifier(identifierName, location: location),
                     arguments: arguments,
                     location: location)
    }

}
