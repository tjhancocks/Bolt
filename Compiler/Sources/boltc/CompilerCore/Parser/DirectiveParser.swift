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

struct DirectiveParser: SubParserProtocol {

    static func test(scanner: Scanner<[Token]>) -> Bool {
        return scanner.test(expected:
            .symbol(symbol: .at, mark: scanner.location),
            .identifier(text: "pragma", mark: scanner.location),
            .symbol(symbol: .leftParen, mark: scanner.location)
        )
    }

    static func parse(scanner: Scanner<[Token]>, owner parser: Parser) throws -> AbstractSyntaxTree.Expression {
        let location = scanner.location
        
        // Skip over the first 3 tokens as they should be '@' 'pragma' '('
        scanner.advance(by: 3)

        // The next part is the domain/namespace that this effects.
        guard case let .identifier(namespace, _)? = scanner.peek() else {
            throw Error.parserError(location: scanner.location,
                                    reason: .unexpectedTokenEncountered(token: scanner.advance()))
        }
        scanner.advance()

        // Expect a ','
        guard case .symbol(.comma, _) = scanner.advance() else {
            throw Error.parserError(location: scanner.location,
                                    reason: .unexpectedTokenEncountered(token: scanner.advance()))
        }

        // The actual flag/information to be given to the namespace.
        guard case let .string(value, _)? = scanner.peek() else {
            throw Error.parserError(location: scanner.location,
                                    reason: .unexpectedTokenEncountered(token: scanner.advance()))
        }
        scanner.advance()

        // Expect a final ')'
        guard case .symbol(.rightParen, _) = scanner.advance() else {
            throw Error.parserError(location: scanner.location,
                                    reason: .unexpectedTokenEncountered(token: scanner.advance()))
        }

        // Construct the appropriate expression for this directive.
        switch namespace {
        case "linker":
            return .linkerFlag(flag: value, location: location)

        default:
            throw Error.parserError(location: location,
                                    reason: .unknownCompilerNamespace(name: namespace))
        }
    }

}
